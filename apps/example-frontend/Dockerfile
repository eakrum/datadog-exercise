# build stage
FROM node:16-buster AS build-stage
ARG TODO_API_URL
ENV REACT_APP_TODO_API_URL ${TODO_API_URL}
# Create app directory
WORKDIR /app
# Copy all files to working dir (/app)
COPY . .

RUN npm install
RUN npm run build

# production stage
FROM nginx:1.15
COPY --from=build-stage /app/build/ /usr/share/nginx/html
COPY --from=build-stage /app/nginx/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
