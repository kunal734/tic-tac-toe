# -------- Stage 1: Build React App --------
FROM node:18 AS builder

WORKDIR /app

# copy package files
COPY package*.json ./

# install dependencies
RUN npm install

# copy project files
COPY . .

# build the app
RUN npm run build


# -------- Stage 2: Serve with Nginx --------
FROM nginx:alpine

# remove default nginx static files
RUN rm -rf /usr/share/nginx/html/*

# copy build files from previous stage
COPY --from=builder /app/dist /usr/share/nginx/html

# expose port
EXPOSE 80

# start nginx
CMD ["nginx", "-g", "daemon off;"]