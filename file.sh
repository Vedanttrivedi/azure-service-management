#!/bin/bash

resource_group=$1
action=$2


web_apps=$(az resource list --resource-group $resource_group --resource-type "Microsoft.Web/sites" --output tsv | grep -e "app,linux" | cut -f6)
for web_app in $web_apps; do
    echo "Performing $action on Azure Web App instance: $web_app"
    az webapp $action --name $web_app --resource-group $resource_group --output none
    echo "Azure Web App instance $action: $web_app"
done

stream_analytics=$(az resource list --resource-group $resource_group --resource-type "Microsoft.StreamAnalytics/streamingjobs" --query "[].name" --output tsv)
for analytics_instance in $stream_analytics; do
    echo "Performing $action on Azure Stream Analytics Jobs instance: $analytics_instance"
    az resource invoke-action --action $action --name $analytics_instance --resource-group $resource_group --resource-type "Microsoft.StreamAnalytics/streamingjobs" --output none
done

postgres_servers=$(az resource list --resource-group $resource_group --resource-type "Microsoft.DBforPostgreSQL/flexibleServers" --query "[].name" --output tsv)
for server_instance in $postgres_servers; do
    echo "Performing $action on Azure PostgreSQL instance: $server_instance"
    az resource invoke-action --action $action --name $server_instance --resource-group $resource_group --resource-type "Microsoft.DBforPostgreSQL/flexibleServers" --output none
done
