# Interactive Blackboard - Spring WebSockets with React, P5.js and Redis

## Project Description

This is a real-time interactive blackboard application that allows multiple users to draw simultaneously on a shared canvas. The application uses:

- **Spring Boot** for the backend server
- **WebSockets** for real-time communication
- **React** for the frontend components
- **P5.js** for canvas drawing functionality
- **Redis** for ticket-based authentication and session management
- **Ticket-based Authentication** for secure access control

Users must obtain a valid ticket from the server before they can draw on the canvas. Their drawings are instantly shared with all other authenticated users through WebSocket connections.

## Architecture

### Backend Components

1. **BBAppStarter.java** - Main Spring Boot application entry point with environment-based port configuration
2. **BBEndpoint.java** - WebSocket endpoint that handles real-time communication between clients with ticket validation
3. **DrawingServiceController.java** - REST controller providing server status and ticket generation
4. **BBConfigurator.java** - WebSocket configuration
5. **RedisConfig.java** - Redis configuration for cache and session management
6. **TicketRepository.java** - Repository for managing authentication tickets using Redis
7. **BBApplicationContextAware.java** - Spring context aware component for dependency injection in WebSocket endpoints

### Frontend Components

1. **index.html** - Main HTML page that loads React, P5.js, and Babel
2. **bbComponents.jsx** - React components including:
   - `Editor` - Main layout component
   - `BBCanvas` - Drawing canvas component with P5.js integration
   - `WSBBChannel` - WebSocket communication class with ticket authentication
   - URL configuration functions for different service endpoints

## Features

- **Ticket-based Authentication**: Users must obtain valid tickets before accessing the drawing functionality
- **Real-time Drawing**: Draw on the canvas and see other users' drawings in real-time
- **WebSocket Communication**: Efficient real-time data exchange between authenticated clients
- **Redis Integration**: Persistent ticket management and session storage
- **Responsive Design**: Works on different screen sizes
- **Environment Configuration**: Automatically adapts to different deployment environments
- **Secure Connections**: Supports both WS (localhost) and WSS (production) protocols

## Prerequisites

- Java 8 or higher
- Maven 3.6 or higher
- Redis Server (6.0 or higher)
- Modern web browser with JavaScript enabled

## Quick Start Scripts (Windows)

For Windows users, I provide convenient batch scripts to manage Redis and the application:

### 1. Setup Redis
```cmd
setup-redis.bat
```
This script will:
- Check if Docker is installed
- Start a Redis container automatically
- Test the Redis connection
- Provide next steps

### 2. Start the Application
```cmd
start-app.bat
```
This script will:
- Check if Redis is running
- Start Redis if needed
- Launch the Spring Boot application
- Open the application at http://localhost:8081

### 3. Stop Everything
```cmd
stop-app.bat
```
This script will:
- Stop the Redis container
- Stop any running Spring Boot processes
- Clean up resources

### 4. Integration Test
```cmd
test-integration.bat
```
This comprehensive test script will:
- Verify Redis connectivity
- Compile the application
- Start all services
- Test all endpoints (health, status, ticket generation)
- Verify WebSocket availability
- Open the application in your browser

## Manual Setup

If you prefer manual setup or are using Linux/macOS:

## Redis Installation

### Windows

1. **Download Redis for Windows**:
   - Download from: https://github.com/MicrosoftArchive/redis/releases
   - Or use Windows Subsystem for Linux (WSL) with Ubuntu

2. **Using Chocolatey** (Recommended):
   ```cmd
   choco install redis-64
   ```

3. **Using WSL**:
   ```bash
   # Install WSL and Ubuntu
   wsl --install
   
   # In WSL terminal:
   sudo apt update
   sudo apt install redis-server
   
   # Start Redis
   sudo service redis-server start
   
   # Test Redis
   redis-cli ping
   ```

4. **Manual Installation**:
   - Extract the downloaded ZIP file
   - Run `redis-server.exe` from the command line
   - Default port: 6379

### Linux/macOS

1. **Ubuntu/Debian**:
   ```bash
   sudo apt update
   sudo apt install redis-server
   sudo systemctl start redis-server
   sudo systemctl enable redis-server
   ```

2. **CentOS/RHEL**:
   ```bash
   sudo yum install redis
   sudo systemctl start redis
   sudo systemctl enable redis
   ```

3. **macOS (using Homebrew)**:
   ```bash
   brew install redis
   brew services start redis
   ```

### Verify Redis Installation

```bash
# Test Redis connection
redis-cli ping
# Should return: PONG

# Check Redis status
redis-cli info server
```

## Installation and Setup

1. **Install Redis** (see Redis Installation section above)

2. **Clone the repository**
   ```bash
   git clone https://github.com/AnderssonProgramming/spring-sockets-rt-p5.git
   cd spring-sockets-rt-p5
   ```

3. **Configure Redis** (Optional - defaults work for local development)
   Edit `src/main/resources/application.properties`:
   ```properties
   # Redis configuration for BB Cache
   redis.bbcache.hostname=localhost
   redis.bbcache.port=6379
   
   # Redis for session management
   spring.redis.host=localhost
   spring.redis.port=6379
   # spring.redis.password=your_password  # if password is required
   ```

4. **Build the project**
   ```bash
   mvn clean compile
   ```

5. **Install dependencies** (if needed)
   ```bash
   mvn dependency:copy-dependencies
   ```

## Running the Application

### Start Redis First
Make sure Redis is running before starting the application:

```bash
# Windows (if installed manually)
redis-server.exe

# Linux/macOS
redis-server

# WSL (Ubuntu)
sudo service redis-server start

# Using Docker
docker run -d -p 6379:6379 redis:latest
```

### Start the Application

#### Option 1: Using Maven (Recommended)
```bash
mvn spring-boot:run
```

#### Option 2: Using Java directly

**For Windows:**
```cmd
java -cp target/classes;target/dependency/* edu.eci.arsw.spring_sockets_rt_p5.BBAppStarter
```

**For Linux/macOS:**
```bash
java -cp target/classes:target/dependency/* edu.eci.arsw.spring_sockets_rt_p5.BBAppStarter
```

#### Option 3: Using the compiled JAR
```bash
java -jar target/spring-sockets-rt-p5-1.0-SNAPSHOT.jar
```

## Authentication Flow

### How Ticket Authentication Works

1. **Client connects** to the web application
2. **Canvas component loads** and attempts to establish WebSocket connection
3. **Before drawing is allowed**, the client must:
   - Make a REST call to `/getticket` endpoint
   - Receive a unique ticket from the server
   - Send this ticket as the first message in the WebSocket connection
4. **Server validates** the ticket using Redis storage
5. **If ticket is valid**:
   - Client is authenticated and can start drawing
   - Drawing coordinates are broadcast to other authenticated clients
6. **If ticket is invalid**:
   - WebSocket connection is closed immediately

### Ticket Management

- **Tickets are generated** by the `TicketRepository` and stored in Redis
- **Each ticket is unique** and can only be used once
- **Tickets are automatically removed** from Redis when validated
- **Redis list operations** ensure thread-safe ticket management

## Step-by-Step Component Construction

### 1. Basic React Component
First, we start with a simple React component that renders a welcome message:

```jsx
const root = ReactDOM.createRoot(document.getElementById("root"));
root.render(
    <h1>Bienvenido</h1>
);
```

### 2. Main Editor Component
Then we extend it to create the main interface with the primary UI elements:

```jsx
function Editor({name}) {
    return (
        <div>
            <h1>Hello, {name}</h1>
            <hr/>
            <div id="toolstatus"></div>
            <hr/>
            <div id="container"></div>
            <hr/>
            <div id="info"></div>
        </div>
    );
}
```

### 3. Canvas Component with P5.js
We create a component to represent the drawing canvas:

```jsx
function BBCanvas() {
    const [svrStatus, setSvrStatus] = React.useState({loadingState: 'Loading Canvas ...'});
    const myp5 = React.useRef(null);
    
    const sketch = function (p) {
        p.setup = function () {
            p.createCanvas(700, 410);
        }
        
        p.draw = function () {
            if (p.mouseIsPressed === true) {
                p.fill(0, 0, 0);
                p.ellipse(p.mouseX, p.mouseY, 20, 20);
            }
            if (p.mouseIsPressed === false) {
                p.fill(255, 255, 255);
            }
        }
    };

    React.useEffect(() => {
        myp5.current = new p5(sketch, 'container');
        setSvrStatus({loadingState: 'Canvas Loaded'});
    }, []);

    return(
        <div>
            <h4>Drawing status: {svrStatus.loadingState}</h4>
        </div>
    );
}
```

### 4. WebSocket Integration with Ticket Authentication
We add WebSocket functionality with ticket-based authentication:

```jsx
// Service URL configuration functions
function BBServiceURL() {
    var url = WShostURL() + '/bbService';
    console.log("BBService URL Calculada: " + url);
    return url;
}

function ticketServiceURL() {
    var url = RESThostURL() + '/getticket';
    console.log("ticketService URL Calculada: " + url);
    return url;
}

function WShostURL() {
    var host = window.location.host;
    var url = 'ws://' + (host);
    console.log("host URL Calculada: " + url);
    return url;
}

function RESThostURL() {
    var host = window.location.host;
    var protocol = window.location.protocol;
    var url = protocol + '//' + (host);
    console.log("host URL Calculada: " + url);
    return url;
}

// Ticket retrieval function
async function getTicket() {
    const response = await fetch(ticketServiceURL());
    console.log("ticket: " + response);
    return response;
}

// WebSocket communication class with authentication
class WSBBChannel {
    constructor(URL, callback) {
        this.URL = URL;
        this.wsocket = new WebSocket(URL);
        this.wsocket.onopen = (evt) => this.onOpen(evt);
        this.wsocket.onmessage = (evt) => this.onMessage(evt);
        this.wsocket.onerror = (evt) => this.onError(evt);
        this.receivef = callback;
    }
    
    async onOpen(evt) {
        console.log("In onOpen", evt);
        var response = await getTicket();
        var json;
        if (response.ok) {
            json = await response.json();
        } else {
            console.log("HTTP-Error: " + response.status);
        }
        this.wsocket.send(json.ticket);
    }
    
    onMessage(evt) {
        console.log("In onMessage", evt);
        if (evt.data != "Connection established.") {
            this.receivef(evt.data);
        }
    }
    
    onError(evt) {
        console.error("In onError", evt);
    }
    
    send(x, y) {
        let msg = '{ "x": ' + (x) + ', "y": ' + (y) + "}";
        console.log("sending: ", msg);
        this.wsocket.send(msg);
    }
}
```

## Accessing the Application

1. **Start Redis server** (see Redis installation section)
2. **Start the application** using one of the methods above
3. Open your web browser
4. Navigate to: `http://localhost:8081` (or the port shown in the console)
5. The application will automatically:
   - Request a ticket from the server
   - Authenticate the WebSocket connection
   - Enable drawing functionality
6. Start drawing on the canvas!
7. Open the same URL in multiple browser tabs to test real-time collaboration

## Configuration

### Port Configuration

The application supports environment-based port configuration following the 12-factor app methodology:

- **Default port**: 8080 (when running locally)
- **Environment port**: Set the `PORT` environment variable for production deployments

Example:
```bash
export PORT=3000
java -jar target/spring-sockets-rt-p5-1.0-SNAPSHOT.jar
```

### Redis Configuration

The application uses two separate Redis configurations:

1. **Session Management** (Spring Session):
   ```properties
   spring.session.store-type=redis
   spring.session.redis.flush-mode=on_save
   spring.session.redis.namespace=blackboard:session
   spring.redis.host=localhost
   spring.redis.port=6379
   ```

2. **BB Cache** (Ticket Management):
   ```properties
   redis.bbcache.hostname=localhost
   redis.bbcache.port=6379
   ```

### WebSocket URL Configuration

The application automatically detects the environment and configures the appropriate WebSocket protocol:

- **Localhost**: Uses `ws://` (unsecured WebSocket)
- **Production**: Uses `wss://` (secured WebSocket)

## API Endpoints

### REST Endpoints

- `GET /status` - Returns server status and current timestamp
- `GET /getticket` - Returns a unique authentication ticket for WebSocket access
- `GET /health` - Returns application health status including Redis connectivity

### WebSocket Endpoints

- `/bbService` - Main WebSocket endpoint for real-time drawing communication (requires ticket authentication)

## How It Works

1. **Client Connection**: User loads the web page and the React application initializes
2. **Ticket Request**: Canvas component requests an authentication ticket via REST API (`/getticket`)
3. **WebSocket Connection**: Client establishes WebSocket connection to `/bbService`
4. **Authentication**: First message sent through WebSocket is the authentication ticket
5. **Ticket Validation**: Server validates ticket using Redis and either accepts or rejects the connection
6. **Drawing Events**: Authenticated users can draw, coordinates are sent via WebSocket
7. **Broadcasting**: Server broadcasts drawing coordinates to all other authenticated clients
8. **Real-time Rendering**: All authenticated clients receive and render drawing coordinates

## Project Structure

```
src/
├── main/
│   ├── java/edu/eci/arsw/spring_sockets_rt_p5/
│   │   ├── BBAppStarter.java              # Main application class
│   │   ├── BBApplicationContextAware.java # Spring context provider
│   │   ├── configurator/
│   │   │   ├── BBConfigurator.java        # WebSocket configuration
│   │   │   └── RedisConfig.java           # Redis configuration
│   │   ├── controllers/
│   │   │   └── DrawingServiceController.java # REST controller (status, tickets)
│   │   ├── endpoints/
│   │   │   └── BBEndpoint.java            # WebSocket endpoint with authentication
│   │   └── repositories/
│   │       └── TicketRepository.java      # Redis-based ticket management
│   └── resources/
│       ├── application.properties         # Spring and Redis configuration
│       └── static/
│           ├── index.html                 # Main HTML page
│           └── js/
│               └── bbComponents.jsx       # React components with authentication
└── test/
    └── java/edu/eci/arsw/spring_sockets_rt_p5/
        └── AppTest.java                   # Unit tests
```

## Technologies Used

- **Spring Boot 3.1.1** - Backend framework
- **Spring WebSocket 6.0.10** - Real-time communication
- **Spring Data Redis 3.1.1** - Redis integration
- **Spring Session 3.1.1** - Session management with Redis
- **Redis** - In-memory data store for tickets and sessions
- **React 18** - Frontend library
- **P5.js 0.7.1** - Canvas drawing library
- **Babel Standalone** - JSX transformation
- **Maven** - Build tool

## Deployment

This application is ready for deployment on cloud platforms. For production deployment:

### Redis Setup
1. **Use a managed Redis service** (AWS ElastiCache, Azure Redis Cache, etc.)
2. **Or deploy Redis instance** on your cloud platform
3. **Update connection properties** for your Redis instance

### Application Configuration
1. **Set environment variables**:
   ```bash
   export PORT=8080
   export REDIS_HOST=your-redis-host
   export REDIS_PORT=6379
   export REDIS_PASSWORD=your-redis-password  # if required
   ```

2. **Update application.properties** for production:
   ```properties
   spring.redis.host=${REDIS_HOST:localhost}
   spring.redis.port=${REDIS_PORT:6379}
   spring.redis.password=${REDIS_PASSWORD:}
   redis.bbcache.hostname=${REDIS_HOST:localhost}
   redis.bbcache.port=${REDIS_PORT:6379}
   ```

## Troubleshooting

### Common Issues

1. **Redis Connection Failed**
   ```
   Error: Cannot connect to Redis at localhost:6379
   ```
   **Solution**: 
   - Ensure Redis server is running
   - Check Redis configuration in application.properties
   - Verify Redis is accessible on the specified host/port

2. **WebSocket Authentication Failed**
   ```
   WebSocket connection closed immediately
   ```
   **Solution**:
   - Check browser console for ticket request errors
   - Verify `/getticket` endpoint is accessible
   - Ensure Redis is storing tickets correctly

3. **Canvas Not Loading**
   - Check browser console for JavaScript errors
   - Ensure all CDN resources are accessible
   - Verify React and P5.js libraries are loaded

4. **Port Already in Use**
   - Change the port using environment variable: `export PORT=9090`
   - Or stop the process using the port: `netstat -ano | findstr :8081`

5. **Compilation Errors**
   - Ensure all Maven dependencies are properly installed
   - Run `mvn clean compile` to rebuild the project
   - Check that Java version is compatible (Java 8+)

### Redis Troubleshooting

1. **Check Redis Status**:
   ```bash
   redis-cli ping  # Should return PONG
   redis-cli info server
   ```

2. **View Redis Logs**:
   ```bash
   # Linux/macOS
   tail -f /var/log/redis/redis-server.log
   
   # Check Redis configuration
   redis-cli CONFIG GET "*"
   ```

3. **Test Ticket Storage**:
   ```bash
   # Connect to Redis CLI
   redis-cli
   
   # Check if tickets are being stored
   LLEN ticketStore
   LRANGE ticketStore 0 -1
   ```

## Maven Dependencies

The project includes the following key dependencies for Redis integration:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
    <version>3.1.1</version>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-websocket</artifactId>
    <version>3.1.1</version>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
    <version>3.1.1</version>
</dependency>
<dependency>
    <groupId>org.springframework.session</groupId>
    <artifactId>spring-session-data-redis</artifactId>
    <version>3.1.1</version>
</dependency>
<dependency>
    <groupId>javax.websocket</groupId>
    <artifactId>javax.websocket-api</artifactId>
    <version>1.1</version>
</dependency>
```

## Development and Testing

### Testing with Multiple Clients

1. Start the application with Redis running
2. Open multiple browser tabs/windows
3. Each tab will:
   - Automatically request a unique ticket
   - Authenticate with the WebSocket endpoint
   - Allow drawing that syncs across all authenticated sessions

### Monitoring Redis Activity

```bash
# Monitor Redis commands in real-time
redis-cli monitor

# Check ticket storage
redis-cli LLEN ticketStore
redis-cli LRANGE ticketStore 0 -1
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with Redis running
5. Submit a pull request

## Future Enhancements

- **Advanced Authentication**: Integration with OAuth2 or JWT tokens
- **User Management**: Named users and persistent user sessions
- **Drawing Tools**: Brush size, colors, shapes selection
- **Room-based Collaboration**: Separate drawing rooms with different access controls
- **Drawing Persistence**: Save and load drawings from Redis or database
- **Mobile Optimization**: Touch support optimization for mobile devices
- **Drawing History**: Undo/redo functionality with Redis-based state management
- **Real-time Chat**: Text chat alongside drawing collaboration
- **Performance Monitoring**: Redis metrics and WebSocket connection monitoring