FROM node:12 as frontend

RUN mkdir /tmp/frontend
WORKDIR /tmp/frontend

# cache hack; fragile
COPY package.json package-lock.json ./
RUN npm install

COPY . .
RUN npm run build

# -----------------------------------------------------------------------------
FROM python:3.7 as backend

RUN mkdir /opt/stayhome-dashboard
WORKDIR /opt/stayhome-dashboard

# todo: reduce to single (sub)directory for easier copying
# Copy front-end files built in previous stage
COPY --from=frontend /tmp/frontend/dashboard/static/js/ /opt/stayhome-dashboard/dashboard/static/js/
COPY --from=frontend /tmp/frontend/dashboard/templates/ /opt/stayhome-dashboard/dashboard/templates/

ENV FLASK_APP=dashboard:create_app

# cache hack; very fragile
COPY requirements.txt ./
RUN pip install --requirement requirements.txt

COPY . .

CMD gunicorn --bind "0.0.0.0:${PORT:-8000}" 'dashboard:create_app()'

EXPOSE 8000
