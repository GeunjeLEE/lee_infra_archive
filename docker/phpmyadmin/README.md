docker run --name myadmin -d -e provider_rds_endpoint=127.0.0.1 -e engagement_rds_endpoint=127.0.0.1 -p 8080:80 [container_name]
docker exec -it myadmin bash
