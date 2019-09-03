require 'json'
require 'net/http'
require 'uri'
require 'date'
require 'time'

JIRA_BASE_URI = "https://m4uservicosdigitais.atlassian.net"

LOGIN_INFO = JSON.parse(File.read(ENV['HOME'] + '/.atlassian/config.json'), symbolize_names: true)
