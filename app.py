from flask import Flask, render_template
import os
import json
import psutil

app = Flask(__name__ , static_folder='templates/static')
data_file = 'traffic_data.json'


def get_network_usage():
    # Use psutil to get network statistics
    net_io = psutil.net_io_counters(pernic=True)
    for interface, stats in net_io.items():
        # Use the first non-loopback interface found
        if not interface.startswith('lo'):
            received_bytes = stats.bytes_recv
            transmitted_bytes = stats.bytes_sent
            return received_bytes, transmitted_bytes
    return 0, 0


def save_data(data):
    with open(data_file, 'w') as f:
        json.dump(data, f)


def load_data():
    if os.path.exists(data_file):
        with open(data_file, 'r') as f:
            return json.load(f)
    return {"received": 0, "transmitted": 0}


@app.route('/')
def index():
    ip = os.getenv('IP', '192.168.1.1')
    phone = os.getenv('PHONE', '123-456-7890')
    max_traffic_gb = os.getenv('TRAFFIC', '100')
    max_traffic_gb = float(max_traffic_gb)
    username = os.getenv('NAME', 'John Doe')
   
    data = load_data()
    
    current_received, current_transmitted = get_network_usage()
    
    # Update total received and transmitted bytes
    data['received'] += current_received
    data['transmitted'] += current_transmitted

    # Save updated data
    save_data(data)

    total_received_gb = data['received'] / (1024 ** 3)
    total_transmitted_gb = data['transmitted'] / (1024 ** 3)
    total_traffic_gb = total_received_gb + total_transmitted_gb
    remaining_traffic_gb = max_traffic_gb - total_traffic_gb

    return render_template('index.html', ip=ip,
                           received=total_received_gb, transmitted=total_transmitted_gb,
                           total=total_traffic_gb, name=username, phone=phone)


if __name__ == '__main__':
    app.run(host='0.0.0.0')
