# Interactive Blackboard - Spring WebSockets with React and P5.js

## Project Description

This is a real-time interactive blackboard application that allows multiple users to draw simultaneously on a shared canvas. The application uses:

- **Spring Boot** for the backend server
- **WebSockets** for real-time communication
- **React** for the frontend components
- **P5.js** for canvas drawing functionality

Users can draw on the canvas with their mouse, and their drawings are instantly shared with all other connected users through WebSocket connections.

## Architecture

### Backend Components

1. **BBAppStarter.java** - Main Spring Boot application entry point with environment-based port configuration
2. **BBEndpoint.java** - WebSocket endpoint that handles real-time communication between clients
3. **DrawingServiceController.java** - REST controller providing server status information
4. **BBConfigurator.java** - WebSocket configuration

### Frontend Components

1. **index.html** - Main HTML page that loads React, P5.js, and Babel
2. **bbComponents.jsx** - React components including:
   - `Editor` - Main layout component
   - `BBCanvas` - Drawing canvas component with P5.js integration
   - `WSBBChannel` - WebSocket communication class
   - `BBServiceURL()` - Service URL configuration function

## Features

- **Real-time Drawing**: Draw on the canvas and see other users' drawings in real-time
- **WebSocket Communication**: Efficient real-time data exchange between clients
- **Responsive Design**: Works on different screen sizes
- **Environment Configuration**: Automatically adapts to different deployment environments
- **Secure Connections**: Supports both WS (localhost) and WSS (production) protocols

## Prerequisites

- Java 8 or higher
- Maven 3.6 or higher
- Modern web browser with JavaScript enabled

## Installation and Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/AnderssonProgramming/spring-sockets-rt-p5.git
   cd spring-sockets-rt-p5
   ```

2. **Build the project**
   ```bash
   mvn clean compile
   ```

3. **Install dependencies** (if needed)
   ```bash
   mvn dependency:copy-dependencies
   ```

## Running the Application

### Option 1: Using Maven (Recommended)
```bash
mvn spring-boot:run
```

### Option 2: Using Java directly

**For Windows:**
```cmd
java -cp target/classes;target/dependency/* edu.eci.arsw.spring_sockets_rt_p5.BBAppStarter
```

**For Linux/macOS:**
```bash
java -cp target/classes:target/dependency/* edu.eci.arsw.spring_sockets_rt_p5.BBAppStarter
```

### Option 3: Using the compiled JAR
```bash
java -jar target/spring-sockets-rt-p5-1.0-SNAPSHOT.jar
```

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

### 4. WebSocket Integration
We add WebSocket functionality for real-time communication:

```jsx
// Service URL configuration function
function BBServiceURL() {
    var host = window.location.host;
    console.log("Host: " + host);
    // En heroku necesita conexiones seguras de web socket
    var url = 'wss://' + (host) + '/bbService';
    if(host.toString().startsWith("localhost")){
        url = 'ws://' + (host) + '/bbService';
    }
    console.log("URL Calculada: " + url);
    return url;
}

// WebSocket communication class
class WSBBChannel {
    constructor(URL, callback) {
        this.URL = URL;
        this.wsocket = new WebSocket(URL);
        this.wsocket.onopen = (evt) => this.onOpen(evt);
        this.wsocket.onmessage = (evt) => this.onMessage(evt);
        this.wsocket.onerror = (evt) => this.onError(evt);
        this.receivef = callback;
    }
    
    onOpen(evt) {
        console.log("In onOpen", evt);
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

1. Start the server using one of the methods above
2. Open your web browser
3. Navigate to: `http://localhost:8080` (or the port shown in the console)
4. Start drawing on the canvas!
5. Open the same URL in multiple browser tabs or different browsers to see real-time collaboration

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

### WebSocket URL Configuration

The application automatically detects the environment and configures the appropriate WebSocket protocol:

- **Localhost**: Uses `ws://` (unsecured WebSocket)
- **Production**: Uses `wss://` (secured WebSocket)

## API Endpoints

### REST Endpoints

- `GET /status` - Returns server status and current timestamp

### WebSocket Endpoints

- `/bbService` - Main WebSocket endpoint for real-time drawing communication

## How It Works

1. **Client Connection**: When a user opens the application, it establishes a WebSocket connection to `/bbService`
2. **Drawing Events**: When a user draws (mouse pressed + movement), the canvas coordinates are sent via WebSocket
3. **Broadcasting**: The server receives drawing coordinates and broadcasts them to all other connected clients
4. **Real-time Rendering**: Other clients receive the coordinates and render the drawing points on their canvas

## Project Structure

```
src/
├── main/
│   ├── java/edu/eci/arsw/spring_sockets_rt_p5/
│   │   ├── BBAppStarter.java              # Main application class
│   │   ├── configurator/
│   │   │   └── BBConfigurator.java        # WebSocket configuration
│   │   ├── controllers/
│   │   │   └── DrawingServiceController.java # REST controller
│   │   └── endpoints/
│   │       └── BBEndpoint.java            # WebSocket endpoint
│   └── resources/
│       ├── application.properties         # Spring configuration
│       └── static/
│           ├── index.html                 # Main HTML page
│           └── js/
│               └── bbComponents.jsx       # React components
└── test/
    └── java/edu/eci/arsw/spring_sockets_rt_p5/
        └── AppTest.java                   # Unit tests
```

## Technologies Used

- **Spring Boot 3.1.1** - Backend framework
- **Spring WebSocket 6.0.10** - Real-time communication
- **React 18** - Frontend library
- **P5.js 0.7.1** - Canvas drawing library
- **Babel Standalone** - JSX transformation
- **Maven** - Build tool

## Deployment

This application is ready for deployment on cloud platforms like Heroku, AWS, or any platform that supports Spring Boot applications:

1. The application automatically detects the PORT environment variable
2. WebSocket connections automatically use secure protocols (WSS) in production
3. All static resources are served from the Spring Boot application

## Troubleshooting

### Common Issues

1. **WebSocket Connection Failed**
   - Ensure the server is running
   - Check browser console for connection errors
   - Verify firewall settings allow WebSocket connections

2. **Canvas Not Loading**
   - Check browser console for JavaScript errors
   - Ensure all CDN resources are accessible
   - Verify React and P5.js libraries are loaded

3. **Port Already in Use**
   - Change the port using environment variable: `export PORT=9090`
   - Or terminate the process using the port

4. **Compilation Errors**
   - Ensure all Maven dependencies are properly installed
   - Run `mvn clean compile` to rebuild the project
   - Check that Java version is compatible (Java 8+)

## Maven Dependencies

The project includes the following key dependencies:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
    <version>3.1.1</version>
</dependency>
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-websocket</artifactId>
    <version>6.0.10</version>
</dependency>
<dependency>
    <groupId>javax.websocket</groupId>
    <artifactId>javax.websocket-api</artifactId>
    <version>1.1</version>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-websocket</artifactId>
    <version>3.1.1</version>
</dependency>
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Future Enhancements

- User authentication and session management
- Drawing tools (brush size, colors, shapes)
- Save and load drawings
- Room-based collaboration
- Mobile touch support optimization
- Drawing history and undo functionality