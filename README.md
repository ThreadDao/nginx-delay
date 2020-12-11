# nginx-delay
## introduction
The problem we solve is to config `delay` directive in `nginx.conf` to delay a few time before requesting.
In short, we compile [`nginx-delay-module`](https://github.com/perusio/nginx-delay-module) into nginx, and build `nginx-delay` image by Dockfile. This image enables a delay directive to be used when serving a request.
## image
- build `nginx-delay` image
 ```
	  docker build -t nginx-delay:v0.1 .
 ```
- run
```
	  docker run --name my-nginx -p 19530:19530 -v /home/nginx/conf/nginx.conf:/etc/nginx/nginx.conf:ro -d nginx-delay:v0.1
 ```
 - nginx.conf
 ```
 events {}
http {
    client_max_body_size 1024M;
    upstream rwserver {
        server 172.16.50.x:1953x;
    }

    upstream roserver {
        server 172.16.50.x:1953x;
        server 172.16.50.x:1953x;
    }

    # access_log  /usr/local/nginx/logs/access.log;


    server {
        listen 19530 http2;

        location ~* ^/milvus.grpc.MilvusService/.+ {
            grpc_pass grpc://rwserver;
        }

        location = /milvus.grpc.MilvusService/Search {
            delay 500ms;
            grpc_pass grpc://roserver;
        }

    }
}
 ```
