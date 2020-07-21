## 개요

openstack의 neutron에서 사용되는 ovs(openvswitch)의 port설정 중, fail_mode에 관한
통신관련 이슈 정리

## 문제
neutron_server / network_node / lbaas_node / compute_node(DVR 구성)에서
`neutron_openvswitch_agent`를 재기동 하는 과정에서 통신 단절이 발생

## 원인
확인 결과, compute노드의 ovs-bridge에는 fail_mode가 있는데, <br>아래의 흐름과 같이 fail_mode의 설정이 변경되면서 통신이 단절됨.

1. 2015.1.1 버전의 neutron패키지에는 `neutron_openvswitch_agent`가 재기동하는 과정에서, ovs-port에 대해 fail_mode를 secure로 설정하도록 되어있음.
2. 단, 2015.1.1버전에서는 br-int만을 설정하고, 2015.13.0이후부터 br-int, br-vlan, br-public등의 port에 대해서 설정하도록 Patch가 됨.
3. ovs의 경우, fail_node가 변경될 시, bridge의 룰이 모두 삭제되고 재설정됨
4. 재설정이 끝날 때 까지 통신이 단절됨(DVR구성으로 인해, compute노드의 ovs-bridge로 통신하므로.)


### 해당 코드
```diff
 def setup_integration_br(self):
        '''Setup the integration bridge.

        Delete patch ports and remove all existing flows.
        '''
        # Ensure the integration bridge is created.
        # ovs_lib.OVSBridge.create() will run
        #   ovs-vsctl -- --may-exist add-br BRIDGE_NAME
        # which does nothing if bridge already exists.
        self.int_br.create()
        self.int_br.set_secure_mode()★

        self.int_br.delete_port(cfg.CONF.OVS.int_peer_patch_port)
        self.int_br.remove_all_flows()
        # switch all traffic using L2 learning
        self.int_br.add_flow(priority=1, actions="normal")
        # Add a canary flow to int_br to track OVS restarts
        self.int_br.add_flow(table=constants.CANARY_TABLE, priority=0,
                             actions="drop")
                             
                             
    def setup_physical_bridges(self, bridge_mappings):
        '''Setup the physical network bridges.

        Creates physical network bridges and links them to the
        integration bridge using veths or patch ports.

        :param bridge_mappings: map physical network names to bridge names.
        '''
        self.phys_brs = {}
        self.int_ofports = {}
        self.phys_ofports = {}
        ip_wrapper = ip_lib.IPWrapper()
        ovs = ovs_lib.BaseOVS()
        ovs_bridges = ovs.get_bridges()
        for physical_network, bridge in bridge_mappings.iteritems():
            LOG.info(_LI("Mapping physical network %(physical_network)s to "
                         "bridge %(bridge)s"),
                     {'physical_network': physical_network,
                      'bridge': bridge})
            # setup physical bridge
            if bridge not in ovs_bridges:
                LOG.error(_LE("Bridge %(bridge)s for physical network "
                              "%(physical_network)s does not exist. Agent "
                              "terminated!"),
                          {'physical_network': physical_network,
                           'bridge': bridge})
                sys.exit(1)
            br = ovs_lib.OVSBridge(bridge)
-           br.remove_all_flows()
-           br.add_flow(priority=1, actions="normal")　★ 2015.1.1에는br_int이외에는 secure로 설정하지 않음.
+           br.set_agent_uuid_stamp(self.agent_uuid_stamp)
+           br.set_secure_mode()★2015.13.0부터 대응 시작
            br.add_flow(priority=1, actions="normal")
            self.phys_brs[physical_network] = br
```
## fail_mode란?
openvswitch의 설정에서 [openflow](https://d2.naver.com/helloworld/387756)의 컨트롤러를 흐름(flow)정보를 제어하기 위한 컨트롤 타워로써 설정이 가능한데.(* OpenFlow는 SDN을 구현하기 위해 처음으로 제정된 표준 인터페이스)

* ovs가 openflow Controller와 연결되지 않는 경우, ovs의 bridge가 어떻게 동작할지를 정의함
* standalone와 secure가있고,default는 standalone
    * standalone : controller를 잃었을 때, MAC-learning switch로써 동작함
    * Secure : 패킷 흐름 관리를 controller에 모두 맡기며, controller를 잃었을 때 모든 패킷을 Drop함

```
fail_mode: optional string, either secure or standalone
When a controller is configured, it is, ordinarily, responsible for setting up all flows on the switch.  Thus, if the connection to the controller fails, no new network connections can be setup. 
If the connection to the controller stays down long enough, no packets can pass through the switch  at  all. 

This  setting determines the switch's response to such a situation.  It maybe set to one of the following

*standalone*  If no message is received from the controller  for three times the  inactivity  probe  interval  (see inactiv-ity_probe), then Open vSwitch will take over responsibil-ity  for  setting  up  flows.  

In this mode, OpenvSwitch causes the bridge to act like  an  ordinary MAC-learning switch.   Open  vSwitch will continue to retry connecting to the controller in the background and, when the connec-tion  succeeds, it will discontinue its standalone behav-ior.

*secure* Open vSwitch will not set up flows on its  own  when the controller  connection  fails  or when no controllersare  defined.  

The bridge will continue to retry connecting to any defined controllers forever.If this value is unset, the default is implementation-specific.
When  more  than one controller is configured, fail_mode is con-sidered only when none of the configured controllers can be con-tacted.
Changing  fail_mode  when  no primary controllers are configured clears the flow table.
```

### 왜 secure로 한 것인가?
* standalone은, Controller를 잃었을 경우, MAC-learning switch로 동작하게 되지만, 이것으로 인해 broadcast에 대해 loop(flooding)가 발생할 수 있음.
* openstack환경에서 ovs는 Controller를 설정하지 않지만, `neutron_openvswitch_agent`가 재기동 되면서 fail_mode에 빠지는 경우가 발생 = flooding 발생
* secure모드에서는 해당 현상이 발생하지 않는 것을 확인하여 패치했다는 내용이 커뮤니티에서도 언급됨
    * https://bugs.launchpad.net/neutron/+bug/1607787


## 대처 
* ovs_bridge의 fail_mode설정을 수동으로 secure로 설정.
```
$ ovs-vsctl set-fail-mode [Bridge Name] secure
```

## 그 외
* ovs-bride정보 확인
```
$ ovs-vsctl show
```
* ovs로그 확인(from DB)
```
$ ovsdb-tool show-log
$ ovsdb-tool show-log | grep secure
```