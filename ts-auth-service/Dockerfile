FROM eclipse-temurin:8-jre-alpine

RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo 'Asia/Shanghai' > /etc/timezone && \
    apk del tzdata

ADD ./target/ts-auth-service-1.0.jar /app/
CMD ["java", "-Xmx200m",  "-jar", "/app/ts-auth-service-1.0.jar"]

EXPOSE 12349