FROM nginx:alpine

# Install curl and bash for HealthChecks
RUN apk add --no-cache curl bash jq

# Copy the NGINX configuration file
COPY nginx.conf /etc/nginx/nginx.conf

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh

# Make the entrypoint script executable
RUN chmod +x /entrypoint.sh

# Expose HTTPS port
EXPOSE 443

# Run the entrypoint script
CMD ["/entrypoint.sh"]