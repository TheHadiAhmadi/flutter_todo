# Use Flutter SDK base image
FROM cirrusci/flutter:stable AS build

WORKDIR /app

# Copy project files
COPY . .

# Enable Flutter web & get packages
RUN flutter channel stable \
  && flutter upgrade \
  && flutter config --enable-web \
  && flutter pub get

# Build the web app
RUN flutter build web

# Stage 2: Serve with nginx
FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
