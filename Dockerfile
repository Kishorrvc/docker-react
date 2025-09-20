FROM node:alpine AS builder

WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
RUN npm run build

FROM nginx
EXPOSE 80
COPY --from=builder /app/build /usr/share/nginx/html

# Useful commands
#  1514  docker build -t kishorrvcmvit/i-react-prod .
#  1515  docker run -d -p 8080:80 --name c-react-prod kishorrvcmvit/i-react-prod 
#  1516  docker logs c-react-prod
#  1517  curl localhost:8080
