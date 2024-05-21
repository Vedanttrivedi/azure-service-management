#!/bin/bash

resource_group=$1
args=$2
action=$(echo "$args" | tr '[:upper:]' '[:lower:]')


echo "updated action value $action"


if [ "$action" != "start" ] && [ "$action" != "stop" ]; then
    echo "Action '$action' is not supported. Please use 'start' or 'stop'.";
    exit 1
fi

webapp() {
    resource_group=$1
    action=$2

    echo "Action: $action"
    echo "Resource Group: $resource_group"

    web_apps=$(az resource list --resource-group $resource_group --resource-type "Microsoft.Web/sites" --output tsv | grep -e "app,linux" | cut -f9)
    for web_app in $web_apps; do
        current_status=$(az webapp show --resource-group $resource_group --name $web_app --query "state" --output tsv)
        echo "Current status of Azure Web App instance $web_app: $current_status"

        update="false"

        if [ "$action" = "stop" ] && [ "$current_status" = "Running" ]; then
            update="true"
        elif [ "$action" = "start" ] && [ "$current_status" = "Stopped" ]; then
            update="true"
        fi

        echo "Update value for $web_app: $update"

        if [ "$update" = "true" ] && [ "$action" = "stop" ]; then
            echo "Stopping Azure Web App instance: $web_app"
            az webapp stop --name $web_app --resource-group $resource_group --output none
            echo "Azure Web App instance stopped: $web_app"
        elif [ "$update" = "true" ] && [ "$action" = "start" ]; then
            echo "Starting Azure Web App instance: $web_app"
            az webapp start --name $web_app --resource-group $resource_group --output none
            echo "Azure Web App instance started: $web_app"
        else
            echo "Skipping $action on Azure Web App instance: $web_app as it is in $current_status state."
        fi
    done
}

postgres_flexible() {
    resource_group=$1
    action=$2

    echo "Action: $action"
    echo "Resource Group: $resource_group"

    postgres_servers=$(az resource list --resource-group $resource_group --resource-type "Microsoft.DBforPostgreSQL/flexibleServers" --query "[].name" --output tsv)
    for server_instance in $postgres_servers; do
        current_status=$(az postgres flexible-server show --resource-group $resource_group --name $server_instance --query "state" --output tsv)
        echo "Current status of Azure PostgreSQL instance $server_instance: $current_status"

        update="false"

        if [ "$action" = "stop" ] && [ "$current_status" = "Ready" ]; then
            update="true"
        elif [ "$action" = "start" ] && [ "$current_status" = "Stopped" ]; then
            update="true"
        fi

        echo "Update value for $server_instance: $update"

        if [ "$update" = "true" ] && [ "$action" = "stop" ]; then
            echo "Stopping Azure PostgreSQL instance: $server_instance"
            az postgres flexible-server stop --name $server_instance --resource-group $resource_group --output none
            echo "Azure PostgreSQL instance stopped: $server_instance"
        elif [ "$update" = "true" ] && [ "$action" = "start" ]; then
            echo "Starting Azure PostgreSQL instance: $server_instance"
            az postgres flexible-server start --name $server_instance --resource-group $resource_group --output none
            echo "Azure PostgreSQL instance started: $server_instance"
        else
            echo "Skipping $action on Azure PostgreSQL instance: $server_instance as it is in $current_status state."
        fi
    done
}

stream_analytics() {
    resource_group=$1
    action=$2

    echo "Action: $action"
    echo "Resource Group: $resource_group"

    stream_analytics=$(az resource list --resource-group $resource_group --resource-type "Microsoft.StreamAnalytics/streamingjobs" --query "[].name" --output tsv)
    for analytics_instance in $stream_analytics; do
        echo "Checking the state of Azure Stream Analytics Job instance: $analytics_instance"

        job_state=$(az stream-analytics job show --resource-group $resource_group --name $analytics_instance  --output tsv | cut -f 15)
        
        echo "Current state of $analytics_instance: $job_state"
        
        update="false"

        if [ "$action" = "stop" ]; then
            if [ "$job_state" = "Idle" ] || [ "$job_state" = "Processing" ] || [ "$job_state" = "Degraded" ] || [ "$job_state" = "Starting" ] || [ "$job_state" = "Restarting" ] || [ "$job_state" = "Scaling" ] || [ "$job_state" = "Running" ]; then
                update="true"
            fi
        elif [ "$action" = "start" ]; then
            update="true"
        fi

        echo "Update value for $analytics_instance: $update"

        if [ "$update" = "true" ] && [ "$action" = "stop" ]; then
            echo "Stopping Azure Stream Analytics Job instance: $analytics_instance"
            az stream-analytics job stop --name $analytics_instance --resource-group $resource_group --output none
            echo "Azure Stream Analytics Job instance stopped: $analytics_instance"
        elif [ "$update" = "true" ] && [ "$action" = "start" ]; then
            echo "Starting Azure Stream Analytics Job instance: $analytics_instance"
            az stream-analytics job start --name $analytics_instance --resource-group $resource_group --output none
            echo "Azure Stream Analytics Job instance started: $analytics_instance"
        else
            echo "Skipping $action on Azure Stream Analytics Job instance: $analytics_instance as it is in $job_state state."
        fi
    done
}

webapp "$resource_group" "$action"
postgres_flexible "$resource_group" "$action"
stream_analytics "$resource_group" "$action"
