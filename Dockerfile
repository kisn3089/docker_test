# node 이미지 기반 Docker 이미지 생성
FROM node:18-alpine AS develop
# 작업 디렉토리 설정
WORKDIR /app
COPY package.json .
# 의존성 설치 명령어 실행
RUN yarn
# 현재 디렉토리의 모든 파일을 도커 컨테이너의 작업 디렉토리에 복사
COPY . .
# 3000번 포트 노출
EXPOSE 3000
# npm start 스크립트 실행
CMD ["yarn","run","dev"]

FROM node:18-alpine AS build-prod
WORKDIR /build
COPY package.json .
RUN yarn
COPY . .
RUN yarn run build

FROM nginx:latest AS deploy
# RUN rm /etc/nginx/conf.d/default.conf
RUN rm -rf /etc/nginx/conf.d
COPY --from=build-prod /build/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]