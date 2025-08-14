function enrich_container_logs(tag, timestamp, record)
    -- Extract container ID from the log file path
    local container_id = nil
    if record["container_path"] then
        container_id = string.match(record["container_path"], "/var/lib/docker/containers/([^/]+)/")
    end
    
    -- Map container IDs to service names based on known container names
    local service_name = "unknown"
    
    -- Note: Docker container IDs are long hashes, but we need to map to service names
    -- This requires reading container metadata or using container names
    if container_id then
        -- Add the full container ID for reference
        record["container_id"] = container_id
        record["container_short_id"] = string.sub(container_id, 1, 12)
        
        -- Try to determine service name from container name if available
        -- This will need to be enhanced based on actual container inspection
        if record["container_name"] then
            local container_name = record["container_name"]
            if string.match(container_name, "club_app") then
                service_name = "club_app"
            elseif string.match(container_name, "club_queue") then
                service_name = "club_queue"
            elseif string.match(container_name, "club_postgres") then
                service_name = "postgres"
            elseif string.match(container_name, "postgres") then
                service_name = "postgres"
            end
        end
    end
    
    -- Add service identification field for UI filtering
    record["service"] = service_name
    record["environment"] = "staging"
    
    -- Add timestamp for better log ordering
    record["@timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S.000Z", timestamp)
    
    return 1, timestamp, record
end