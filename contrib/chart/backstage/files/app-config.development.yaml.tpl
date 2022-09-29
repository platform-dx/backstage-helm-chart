backend:
  lighthouseHostname: {{ include "lighthouse.serviceName" . | quote }}
  listen:
      port: {{ .Values.appConfig.backend.listen.port | default 7007 }}
  database:
    client: {{ .Values.appConfig.backend.database.client | quote }}
    connection:
      host: {{ include "backend.postgresql.host" . | quote }}
      port: {{ include "backend.postgresql.port" . | quote }}
      user: {{ include "backend.postgresql.user" . | quote }}
      database: {{ .Values.appConfig.backend.database.connection.database | quote }}
      ssl:
        rejectUnauthorized: {{ .Values.appConfig.backend.database.connection.ssl.rejectUnauthorized | quote }}
        ca: {{ include "backstage.backend.postgresCaFilename" . | quote }}

catalog:
{{- if .Values.backend.demoData }}
  import:
    entityFilename: catalog-info.yaml
    pullRequestBranchName: backstage-integration
  rules:
    - allow: [Component, System, API, Group, User, Resource, Location]
  locations:
    - type: url
      target: https://github.com/twlabs/empc-demo-backstage-frontend/blob/main/template.yaml
      rules:
        - allow: [Template]
    - type: url
      target: https://github.com/twlabs/empc-demo-backstage-openapi/blob/main/template.yaml
      rules:
        - allow: [Template]
{{- else }}
  locations: []
{{- end }}

integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}

proxy:
  '/circleci/api':
    target: https://circleci.com/api/v1.1
    headers:
      Circle-Token: ${CIRCLECI_AUTH_TOKEN}

  '/sonarqube':
    target: '{{ .Values.appConfig.sonarqube.baseUrl }}/api'
    allowedMethods: ['GET']
    auth: '${SONARQUBE_AUTH_TOKEN}:'

sonarqube:
  baseUrl: {{ .Values.appConfig.sonarqube.baseUrl }}
  apiKey: ${SONARQUBE_AUTH_TOKEN}

auth:
  environment: development
  providers:
    github:
      development:
        clientId: ${GITHUB_CLIENT_ID}
        clientSecret: ${GITHUB_CLIENT_SECRET}

scaffolder:
  defaultAuthor:
    name: EMPC DX
    email: empc-dx@thoughtworks.com
  defaultCommitMessage: "Platform DX ++"


sentry:
  organization: {{ .Values.appConfig.sentry.organization | quote }}

techdocs:
  builder: 'local'
  generator:
    runIn: 'local'
  publisher:
    type: 'local'
