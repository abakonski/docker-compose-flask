FROM python:3.6

# Set up environment variables
ENV NGINX_VERSION '1.10.3-1+deb9u1'

# Install dependencies
RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
    && echo "deb http://httpredir.debian.org/debian/ stretch main contrib non-free" >> /etc/apt/sources.list \
    && echo "deb-src http://httpredir.debian.org/debian/ stretch main contrib non-free" >> /etc/apt/sources.list \
    && apt-get update -y \
    && apt-get install -y -t stretch openssl nginx-extras=${NGINX_VERSION} \
    && apt-get install -y nano supervisor \
    && rm -rf /var/lib/apt/lists/*


# Expose ports
EXPOSE 80

# Forward request and error logs to Docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# Make NGINX run on the foreground
RUN if ! grep --quiet "daemon off;" /etc/nginx/nginx.conf ; then echo "daemon off;" >> /etc/nginx/nginx.conf; fi;

# Remove default configuration from Nginx
RUN rm -f /etc/nginx/conf.d/default.conf \
    && rm -rf /etc/nginx/sites-available/* \
    && rm -rf /etc/nginx/sites-enabled/*

# Copy the modified Nginx conf
COPY /conf/nginx.conf /etc/nginx/conf.d/

# Custom Supervisord config
COPY /conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# COPY requirements.txt and RUN pip install BEFORE adding the rest of your code, this will cause Docker's caching mechanism
# to prevent re-installinig (all your) dependencies when you change a line or two in your app
COPY /app/requirements.txt /home/docker/code/app/
RUN pip3 install -r /home/docker/code/app/requirements.txt

# Copy app code to image
COPY /app /app
WORKDIR /app

# Copy the base uWSGI ini file to enable default dynamic uwsgi process number
COPY /app/uwsgi.ini /etc/uwsgi/
RUN mkdir -p /var/log/uwsgi


CMD ["/usr/bin/supervisord"]
