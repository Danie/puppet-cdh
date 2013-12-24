# == Class cdh4::hadoop::jmxtrans::resourcemanager
# Sets up a jmxtrans instance for a Hadoop ResourceManager
# running on the current host.
# Note: This requires the jmxtrans puppet module found at
# https://github.com/wikimedia/puppet-jmxtrans.
#
# == Parameters
# $jmx_port      - NameNode JMX port.  Default: 9980
# $ganglia       - Ganglia host:port
# $graphite      - Graphite host:port
# $outfile       - outfile to which Kafka stats will be written.
# $objects       - objects parameter to pass to jmxtrans::metrics.  Only use
#                  this if you need to override the default ones that this
#                  class provides.
# $run_interval  - How often jmxtrans should run.        Default: 15
# $log_level     - level at which jmxtrans should log.   Default: info
#
# == Usage
# class { 'cdh4::hadoop::jmxtrans::resourcemanager':
#     ganglia => 'ganglia.example.org:8649'
# }
#
class cdh4::hadoop::jmxtrans::resourcemanager(
    $jmx_port       = $cdh4::hadoop::defaults::resourcemanager_jmxremote_port,
    $ganglia        = undef,
    $graphite       = undef,
    $outfile        = undef,
    $objects        = undef,
    $run_interval   = 15,
    $log_level      = 'info',
) inherits cdh4::hadoop::defaults
{
    $jmx = "${::fqdn}:${jmx_port}"
    $group_name = 'Hadoop.ResourceManager'

    class {'::jmxtrans':
        run_interval => $run_interval,
        log_level    => $log_level,
    }

    # query for metrics from Hadoop NameNode's JVM
    jmxtrans::metrics::jvm { 'hadoop-hdfs-resourcemanager':
        jmx                  => $jmx,
        group_prefix         => "${group_name}.",
        outfile              => $outfile,
        ganglia              => $ganglia,
        graphite             => $graphite,
    }


    $resourcemanager_objects = $objects ? {
        # if $objects was not set, then use this as the
        # default set of JMX MBean objects to query.
        undef   => [
            {
                'name'          => 'Hadoop:name=ClusterMetrics,service=ResourceManager',
                'resultAlias'   => "${group_name}.ClusterMetrics",
                'attrs'         => {
                    'NumActiveNMs'                     => { 'slope' => 'both' },
                    'NumDecommissionedNMs'             => { 'slope' => 'both' },
                    'NumLostNMs'                       => { 'slope' => 'both' },
                    'NumRebootedNMs'                   => { 'slope' => 'both' },
                    'NumUnhealthyNMs'                  => { 'slope' => 'both' },
                },
            },

            {
                'name'          => 'Hadoop:name=JvmMetrics,service=ResourceManager',
                'resultAlias'   => "${group_name}.JvmMetrics",
                'attrs'         => {
                    'GcCount'                          => { 'slope' => 'positive' },
                    'GcCountPS MarkSweep'              => { 'slope' => 'positive' },
                    'GcCountPS Scavenge'               => { 'slope' => 'positive' },
                    'GcTimeMillis'                     => { 'slope' => 'both' },
                    'GcTimeMillisPS MarkSweep'         => { 'slope' => 'both' },
                    'GcTimeMillisPS Scavenge'          => { 'slope' => 'both' },
                    'LogError'                         => { 'slope' => 'positive' },
                    'LogFatal'                         => { 'slope' => 'positive' },
                    'LogInfo'                          => { 'slope' => 'both' },
                    'LogWarn'                          => { 'slope' => 'positive' },
                    'MemHeapCommittedM'                => { 'slope' => 'both' },
                    'MemHeapUsedM'                     => { 'slope' => 'both' },
                    'MemNonHeapCommittedM'             => { 'slope' => 'both' },
                    'MemNonHeapUsedM'                  => { 'slope' => 'both' },
                    'ThreadsBlocked'                   => { 'slope' => 'both' },
                    'ThreadsNew'                       => { 'slope' => 'both' },
                    'ThreadsRunnable'                  => { 'slope' => 'both' },
                    'ThreadsTerminated'                => { 'slope' => 'both' },
                    'ThreadsTimedWaiting'              => { 'slope' => 'both' },
                    'ThreadsWaiting'                   => { 'slope' => 'both' },
                },
            },


            {
                'name'          => 'Hadoop:name=QueueMetrics,q0=root,q1=adhoc,service=ResourceManager',
                'resultAlias'   => "${group_name}.QueueMetrics,q0=root,q1=adhoc",
                'attrs'         => {
                    'ActiveApplications'               => { 'slope' => 'both' },
                    'ActiveUsers'                      => { 'slope' => 'both' },
                    'AggregateContainersAllocated'     => { 'slope' => 'positive' },
                    'AggregateContainersReleased'      => { 'slope' => 'positive' },
                    'AllocatedContainers'              => { 'slope' => 'both' },
                    'AllocatedMB'                      => { 'slope' => 'both' },
                    'AppsCompleted'                    => { 'slope' => 'positive' },
                    'AppsFailed'                       => { 'slope' => 'positive' },
                    'AppsKilled'                       => { 'slope' => 'positive' },
                    'AppsPending'                      => { 'slope' => 'both' },
                    'AppsRunning'                      => { 'slope' => 'both' },
                    'AppsSubmitted'                    => { 'slope' => 'both' },
                    'AvailableMB'                      => { 'slope' => 'both' },
                    'PendingContainers'                => { 'slope' => 'both' },
                    'PendingMB'                        => { 'slope' => 'both' },
                    'ReservedContainers'               => { 'slope' => 'both' },
                    'ReservedMB'                       => { 'slope' => 'both' },
                    'running_0'                        => { 'slope' => 'both' },
                    'running_1440'                     => { 'slope' => 'both' },
                    'running_300'                      => { 'slope' => 'both' },
                    'running_60'                       => { 'slope' => 'both' },
                },
            },

            {
                'name'          => 'Hadoop:name=QueueMetrics,q0=root,q1=default,service=ResourceManager',
                'resultAlias'   => "${group_name}.QueueMetrics,q0=root,q1=default",
                'attrs'         => {
                    'ActiveApplications'               => { 'slope' => 'both' },
                    'ActiveUsers'                      => { 'slope' => 'both' },
                    'AggregateContainersAllocated'     => { 'slope' => 'positive' },
                    'AggregateContainersReleased'      => { 'slope' => 'positive' },
                    'AllocatedContainers'              => { 'slope' => 'both' },
                    'AllocatedMB'                      => { 'slope' => 'both' },
                    'AppsCompleted'                    => { 'slope' => 'positive' },
                    'AppsFailed'                       => { 'slope' => 'positive' },
                    'AppsKilled'                       => { 'slope' => 'positive' },
                    'AppsPending'                      => { 'slope' => 'both' },
                    'AppsRunning'                      => { 'slope' => 'both' },
                    'AppsSubmitted'                    => { 'slope' => 'both' },
                    'AvailableMB'                      => { 'slope' => 'both' },
                    'PendingContainers'                => { 'slope' => 'both' },
                    'PendingMB'                        => { 'slope' => 'both' },
                    'ReservedContainers'               => { 'slope' => 'both' },
                    'ReservedMB'                       => { 'slope' => 'both' },
                    'running_0'                        => { 'slope' => 'both' },
                    'running_1440'                     => { 'slope' => 'both' },
                    'running_300'                      => { 'slope' => 'both' },
                    'running_60'                       => { 'slope' => 'both' },
                },
            },

            {
                'name'          => 'Hadoop:name=QueueMetrics,q0=root,q1=default,service=ResourceManager,user=hdfs',
                'attrs'         => {
                    'ActiveApplications'               => { 'slope' => 'both' },
                    'ActiveUsers'                      => { 'slope' => 'both' },
                    'AggregateContainersAllocated'     => { 'slope' => 'positive' },
                    'AggregateContainersReleased'      => { 'slope' => 'positive' },
                    'AllocatedContainers'              => { 'slope' => 'both' },
                    'AllocatedMB'                      => { 'slope' => 'both' },
                    'AppsCompleted'                    => { 'slope' => 'positive' },
                    'AppsFailed'                       => { 'slope' => 'positive' },
                    'AppsKilled'                       => { 'slope' => 'positive' },
                    'AppsPending'                      => { 'slope' => 'both' },
                    'AppsRunning'                      => { 'slope' => 'both' },
                    'AppsSubmitted'                    => { 'slope' => 'both' },
                    'AvailableMB'                      => { 'slope' => 'both' },
                    'PendingContainers'                => { 'slope' => 'both' },
                    'PendingMB'                        => { 'slope' => 'both' },
                    'ReservedContainers'               => { 'slope' => 'both' },
                    'ReservedMB'                       => { 'slope' => 'both' },
                    'running_0'                        => { 'slope' => 'both' },
                    'running_1440'                     => { 'slope' => 'both' },
                    'running_300'                      => { 'slope' => 'both' },
                    'running_60'                       => { 'slope' => 'both' },
                },
            },

            {
                'name'          => 'Hadoop:name=QueueMetrics,q0=root,q1=standard,service=ResourceManager',
                'resultAlias'   => "${group_name}.QueueMetrics,q0=root,q1=standard",
                'attrs'         => {
                    'ActiveApplications'               => { 'slope' => 'both' },
                    'ActiveUsers'                      => { 'slope' => 'both' },
                    'AggregateContainersAllocated'     => { 'slope' => 'positive' },
                    'AggregateContainersReleased'      => { 'slope' => 'positive' },
                    'AllocatedContainers'              => { 'slope' => 'both' },
                    'AllocatedMB'                      => { 'slope' => 'both' },
                    'AppsCompleted'                    => { 'slope' => 'positive' },
                    'AppsFailed'                       => { 'slope' => 'positive' },
                    'AppsKilled'                       => { 'slope' => 'positive' },
                    'AppsPending'                      => { 'slope' => 'both' },
                    'AppsRunning'                      => { 'slope' => 'both' },
                    'AppsSubmitted'                    => { 'slope' => 'both' },
                    'AvailableMB'                      => { 'slope' => 'both' },
                    'PendingContainers'                => { 'slope' => 'both' },
                    'PendingMB'                        => { 'slope' => 'both' },
                    'ReservedContainers'               => { 'slope' => 'both' },
                    'ReservedMB'                       => { 'slope' => 'both' },
                    'running_0'                        => { 'slope' => 'both' },
                    'running_1440'                     => { 'slope' => 'both' },
                    'running_300'                      => { 'slope' => 'both' },
                    'running_60'                       => { 'slope' => 'both' },
                },
            },

            {
                'name'          => 'Hadoop:name=QueueMetrics,q0=root,service=ResourceManager',
                'resultAlias'   => "${group_name}.QueueMetrics,q0=root",
                'attrs'         => {
                    'ActiveApplications'               => { 'slope' => 'both' },
                    'ActiveUsers'                      => { 'slope' => 'both' },
                    'AggregateContainersAllocated'     => { 'slope' => 'positive' },
                    'AggregateContainersReleased'      => { 'slope' => 'positive' },
                    'AllocatedContainers'              => { 'slope' => 'both' },
                    'AllocatedMB'                      => { 'slope' => 'both' },
                    'AppsCompleted'                    => { 'slope' => 'positive' },
                    'AppsFailed'                       => { 'slope' => 'positive' },
                    'AppsKilled'                       => { 'slope' => 'positive' },
                    'AppsPending'                      => { 'slope' => 'both' },
                    'AppsRunning'                      => { 'slope' => 'both' },
                    'AppsSubmitted'                    => { 'slope' => 'both' },
                    'AvailableMB'                      => { 'slope' => 'both' },
                    'PendingContainers'                => { 'slope' => 'both' },
                    'PendingMB'                        => { 'slope' => 'both' },
                    'ReservedContainers'               => { 'slope' => 'both' },
                    'ReservedMB'                       => { 'slope' => 'both' },
                    'running_0'                        => { 'slope' => 'both' },
                    'running_1440'                     => { 'slope' => 'both' },
                    'running_300'                      => { 'slope' => 'both' },
                    'running_60'                       => { 'slope' => 'both' },
                },
            },

            {
                'name'          => 'Hadoop:name=QueueMetrics,q0=root,service=ResourceManager,user=dr.who',
                'attrs'         => {
                    'ActiveApplications'               => { 'slope' => 'both' },
                    'ActiveUsers'                      => { 'slope' => 'both' },
                    'AggregateContainersAllocated'     => { 'slope' => 'positive' },
                    'AggregateContainersReleased'      => { 'slope' => 'positive' },
                    'AllocatedContainers'              => { 'slope' => 'both' },
                    'AllocatedMB'                      => { 'slope' => 'both' },
                    'AppsCompleted'                    => { 'slope' => 'positive' },
                    'AppsFailed'                       => { 'slope' => 'positive' },
                    'AppsKilled'                       => { 'slope' => 'positive' },
                    'AppsPending'                      => { 'slope' => 'both' },
                    'AppsRunning'                      => { 'slope' => 'both' },
                    'AppsSubmitted'                    => { 'slope' => 'both' },
                    'AvailableMB'                      => { 'slope' => 'both' },
                    'PendingContainers'                => { 'slope' => 'both' },
                    'PendingMB'                        => { 'slope' => 'both' },
                    'ReservedContainers'               => { 'slope' => 'both' },
                    'ReservedMB'                       => { 'slope' => 'both' },
                    'running_0'                        => { 'slope' => 'both' },
                    'running_1440'                     => { 'slope' => 'both' },
                    'running_300'                      => { 'slope' => 'both' },
                    'running_60'                       => { 'slope' => 'both' },
                },
            },

            {
                'name'          => 'Hadoop:name=QueueMetrics,q0=root,service=ResourceManager,user=hdfs',
                'attrs'         => {
                    'ActiveApplications'               => { 'slope' => 'both' },
                    'ActiveUsers'                      => { 'slope' => 'both' },
                    'AggregateContainersAllocated'     => { 'slope' => 'positive' },
                    'AggregateContainersReleased'      => { 'slope' => 'positive' },
                    'AllocatedContainers'              => { 'slope' => 'both' },
                    'AllocatedMB'                      => { 'slope' => 'both' },
                    'AppsCompleted'                    => { 'slope' => 'positive' },
                    'AppsFailed'                       => { 'slope' => 'positive' },
                    'AppsKilled'                       => { 'slope' => 'positive' },
                    'AppsPending'                      => { 'slope' => 'both' },
                    'AppsRunning'                      => { 'slope' => 'both' },
                    'AppsSubmitted'                    => { 'slope' => 'both' },
                    'AvailableMB'                      => { 'slope' => 'both' },
                    'PendingContainers'                => { 'slope' => 'both' },
                    'PendingMB'                        => { 'slope' => 'both' },
                    'ReservedContainers'               => { 'slope' => 'both' },
                    'ReservedMB'                       => { 'slope' => 'both' },
                    'running_0'                        => { 'slope' => 'both' },
                    'running_1440'                     => { 'slope' => 'both' },
                    'running_300'                      => { 'slope' => 'both' },
                    'running_60'                       => { 'slope' => 'both' },
                },
            },

            {
                'name'          => 'Hadoop:name=RpcActivityForPort8030,service=ResourceManager',
                'resultAlias'   => "${group_name}.RpcActivityForPort8030",
                'attrs'         => {
                    'CallQueueLength'                  => { 'slope' => 'both' },
                    'NumOpenConnections'               => { 'slope' => 'both' },
                    'ReceivedBytes'                    => { 'slope' => 'positive' },
                    'RpcAuthenticationFailures'        => { 'slope' => 'positive' },
                    'RpcAuthenticationSuccesses'       => { 'slope' => 'positive' },
                    'RpcAuthorizationFailures'         => { 'slope' => 'positive' },
                    'RpcAuthorizationSuccesses'        => { 'slope' => 'positive' },
                    'RpcProcessingTimeAvgTime'         => { 'slope' => 'both' },
                    'RpcProcessingTimeNumOps'          => { 'slope' => 'positive' },
                    'RpcQueueTimeAvgTime'              => { 'slope' => 'both' },
                    'RpcQueueTimeNumOps'               => { 'slope' => 'positive' },
                    'SentBytes'                        => { 'slope' => 'positive' },
                },
            },

            {
                'name'          => 'Hadoop:name=RpcActivityForPort8031,service=ResourceManager',
                'resultAlias'   => "${group_name}.RpcActivityForPort8031",
                'attrs'         => {
                    'CallQueueLength'                  => { 'slope' => 'both' },
                    'NumOpenConnections'               => { 'slope' => 'both' },
                    'ReceivedBytes'                    => { 'slope' => 'positive' },
                    'RpcAuthenticationFailures'        => { 'slope' => 'positive' },
                    'RpcAuthenticationSuccesses'       => { 'slope' => 'positive' },
                    'RpcAuthorizationFailures'         => { 'slope' => 'positive' },
                    'RpcAuthorizationSuccesses'        => { 'slope' => 'positive' },
                    'RpcProcessingTimeAvgTime'         => { 'slope' => 'both' },
                    'RpcProcessingTimeNumOps'          => { 'slope' => 'positive' },
                    'RpcQueueTimeAvgTime'              => { 'slope' => 'both' },
                    'RpcQueueTimeNumOps'               => { 'slope' => 'positive' },
                    'SentBytes'                        => { 'slope' => 'positive' },
                },
            },

            {
                'name'          => 'Hadoop:name=RpcActivityForPort8032,service=ResourceManager',
                'resultAlias'   => "${group_name}.RpcActivityForPort8032",
                'attrs'         => {
                    'CallQueueLength'                  => { 'slope' => 'both' },
                    'NumOpenConnections'               => { 'slope' => 'both' },
                    'ReceivedBytes'                    => { 'slope' => 'positive' },
                    'RpcAuthenticationFailures'        => { 'slope' => 'positive' },
                    'RpcAuthenticationSuccesses'       => { 'slope' => 'positive' },
                    'RpcAuthorizationFailures'         => { 'slope' => 'positive' },
                    'RpcAuthorizationSuccesses'        => { 'slope' => 'positive' },
                    'RpcProcessingTimeAvgTime'         => { 'slope' => 'both' },
                    'RpcProcessingTimeNumOps'          => { 'slope' => 'positive' },
                    'RpcQueueTimeAvgTime'              => { 'slope' => 'both' },
                    'RpcQueueTimeNumOps'               => { 'slope' => 'positive' },
                    'SentBytes'                        => { 'slope' => 'positive' },
                },
            },

            {
                'name'          => 'Hadoop:name=RpcActivityForPort8033,service=ResourceManager',
                'resultAlias'   => "${group_name}.RpcActivityForPort8033",
                'attrs'         => {
                    'CallQueueLength'                  => { 'slope' => 'both' },
                    'NumOpenConnections'               => { 'slope' => 'both' },
                    'ReceivedBytes'                    => { 'slope' => 'positive' },
                    'RpcAuthenticationFailures'        => { 'slope' => 'positive' },
                    'RpcAuthenticationSuccesses'       => { 'slope' => 'positive' },
                    'RpcAuthorizationFailures'         => { 'slope' => 'positive' },
                    'RpcAuthorizationSuccesses'        => { 'slope' => 'positive' },
                    'RpcProcessingTimeAvgTime'         => { 'slope' => 'both' },
                    'RpcProcessingTimeNumOps'          => { 'slope' => 'positive' },
                    'RpcQueueTimeAvgTime'              => { 'slope' => 'both' },
                    'RpcQueueTimeNumOps'               => { 'slope' => 'positive' },
                    'SentBytes'                        => { 'slope' => 'positive' },
                },
            },
        ],

        # else use $objects
        default => $objects,
    }

    # query for jmx metrics
    jmxtrans::metrics { "hadoop-yarn-resourcemanager-${::hostname}-${jmx_port}":
        jmx                  => $jmx,
        outfile              => $outfile,
        ganglia              => $ganglia,
        ganglia_group_name   => $group_name,
        graphite             => $graphite,
        graphite_root_prefix => $group_name,
        objects              => $resourcemanager_objects,
    }
}