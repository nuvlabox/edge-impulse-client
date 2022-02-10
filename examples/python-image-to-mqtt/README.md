# Object Recognition Event Handler in Python

Uses a pre-generated Edge Impulse model to find objects in a given camera frame.
If objects are found, it sends a notification to the NuvlaBox Data Gateway. If the objects are getting
in or out of the frame, it also triggers an alert to the BlackBox topic.

## Configuration

**BLACKBOX_TRIGGER_LABELS:** a comma-separated list of object labels to alert for. When these objects enter or leave the FoV, a BlackBox trigger is sent. For every label, on entering and leaving the frame, a message is also sent to the MQTT broker. Use `all` to alert for all labels.

**MQTT_HOST**: MQTT broker endpoint where to send the messages and BlackBox triggers to. Default is `data-gateway`.

**MQTT_TOPIC**: MQTT topic where to send the detection messages to. Default is `demo`. Note that the BlackBox trigger messages are sent to `blackbox/record`, regardless of this variable.

**EI_API_KEY**: API key to access the Edge Impulse project and download the data processing model.



