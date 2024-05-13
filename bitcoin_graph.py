import sqlite3
import matplotlib.pyplot as plt
import pandas as pd

def plot_graph(data):
    # Convert data to DataFrame
    df = pd.DataFrame(data, columns=['timestamp', 'current_rate', 'low_rate', 'high_rate'])
    
    # Convert timestamp to datetime
    df['timestamp'] = pd.to_datetime(df['timestamp'])
    
    # Convert rate columns to numeric
    for column in ['current_rate', 'low_rate', 'high_rate']:
        df[column] = df[column].str.replace(r'[\$,]', '', regex=True).astype(float)
    
    # Calculate representative rates
    representative_rates = {
        'Average Rate': df['current_rate'].mean(),
        'Minimum Rate': df['low_rate'].min(),
        'Maximum Rate': df['high_rate'].max(),
        '25th Percentile': df['current_rate'].quantile(0.25),
        '75th Percentile': df['current_rate'].quantile(0.75)
    }
    
    # Plot graph
    plt.figure(figsize=(10, 6))
    plt.plot(df['timestamp'], df['current_rate'], label='Current Rate', marker='o')
    plt.plot(df['timestamp'], df['low_rate'], label='Low Rate', marker='o')
    plt.plot(df['timestamp'], df['high_rate'], label='High Rate', marker='o')
    
    # Plot representative rates
    for label, rate in representative_rates.items():
        plt.axhline(y=rate, color='gray', linestyle='--', label=label)
    
    plt.xlabel('Timestamp')
    plt.ylabel('Rate')
    plt.title('Bitcoin Rate')
    plt.legend()
    plt.grid(True)
    plt.xticks(rotation=45)
    plt.tight_layout()
    
    # Save plot
    plt.savefig('/home/jiaen/Documents/COMP1204Coursework2/bitcoin_rate_plot.png')
    plt.close()

def main():
    # Connect to database
    conn = sqlite3.connect('/home/jiaen/Documents/COMP1204Coursework2/bitcoin_data.db')
    cursor = conn.cursor()

    # Fetch all data from the bitcoin_rates table
    cursor.execute("SELECT timestamp, current_rate, low_rate, high_rate FROM bitcoin_rates")
    data = cursor.fetchall()

    # Plot graph
    plot_graph(data)

    # Close database connection
    conn.close()

if __name__ == "__main__":
    main()

