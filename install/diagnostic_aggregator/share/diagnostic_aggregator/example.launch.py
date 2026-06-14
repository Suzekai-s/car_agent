"""Launch analyzer loader with parameters from yaml."""

import launch
import launch_ros.actions

analyzer_params_filepath = "/home/szk/workspace/car_distributed/car_agent/install/diagnostic_aggregator/share/diagnostic_aggregator/example_analyzers.yaml"
add_analyzer_params_filepath = "/home/szk/workspace/car_distributed/car_agent/install/diagnostic_aggregator/share/diagnostic_aggregator/example_add_analyzers.yaml"


def generate_launch_description():
    aggregator = launch_ros.actions.Node(
        package='diagnostic_aggregator',
        executable='aggregator_node',
        output='screen',
        parameters=[analyzer_params_filepath])
    add_analyzer = launch_ros.actions.Node(
        package='diagnostic_aggregator',
        executable='add_analyzer',
        output='screen',
        parameters=[add_analyzer_params_filepath]
    )
    diag_publisher = launch_ros.actions.Node(
        package='diagnostic_aggregator',
        executable='example_pub.py')
    return launch.LaunchDescription([
        aggregator,
        add_analyzer,
        diag_publisher,
        launch.actions.RegisterEventHandler(
            event_handler=launch.event_handlers.OnProcessExit(
                target_action=aggregator,
                on_exit=[launch.actions.EmitEvent(
                    event=launch.events.Shutdown())],
            )),
    ])
