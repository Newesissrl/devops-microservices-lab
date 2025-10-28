const amqp = require('amqplib');

class RabbitMQService {
  constructor() {
    this.connection = null;
    this.channel = null;
  }

  async connect() {
    const maxRetries = 10;
    let retryDelay = 1000;
    
    for (let attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        const rabbitmqUrl = process.env.RABBITMQ_URL || 'amqp://localhost';
        const vhost = process.env.RABBITMQ_VHOST || '/';
        const url = `${rabbitmqUrl}${vhost}`;
        
        console.log(`Attempting RabbitMQ connection (${attempt}/${maxRetries})...`);
        this.connection = await amqp.connect(url);
        this.channel = await this.connection.createChannel();
        
        const exchange = process.env.RABBITMQ_EXCHANGE || 'expenses_exchange';
        await this.channel.assertExchange(exchange, 'topic', { durable: true });
        
        console.log('RabbitMQ connected successfully');
        return;
      } catch (error) {
        console.error(`RabbitMQ connection attempt ${attempt} failed:`, error.message);
        
        if (attempt === maxRetries) {
          console.error('Max RabbitMQ connection retries reached. Continuing without RabbitMQ.');
          return;
        }
        
        console.log(`Retrying in ${retryDelay}ms...`);
        await new Promise(resolve => setTimeout(resolve, retryDelay));
        retryDelay = Math.min(retryDelay * 2, 30000); // Exponential backoff, max 30s
      }
    }
  }

  async publishMessage(routingKey, message) {
    if (!this.channel) {
      console.warn('RabbitMQ not connected, skipping message publish');
      return;
    }

    try {
      const exchange = process.env.RABBITMQ_EXCHANGE || 'expenses_exchange';
      const messageBuffer = Buffer.from(JSON.stringify(message));
      
      await this.channel.publish(exchange, routingKey, messageBuffer, {
        persistent: true,
        timestamp: Date.now()
      });
      
      console.log(`Message published: ${routingKey}`);
    } catch (error) {
      console.error('Failed to publish message:', error.message);
    }
  }

  async close() {
    if (this.connection) {
      await this.connection.close();
    }
  }
}

module.exports = new RabbitMQService();