require 'json'
require 'net/http'
require 'uri'
require 'date'
require 'time'

JIRA_BASE_URI = "https://m4uservicosdigitais.atlassian.net"

CONFIG = JSON.parse(File.read(__dir__ + '/config.json'), symbolize_names: true)
