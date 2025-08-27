# Course Management System

This project consists of two parts:

- **Part 1:** JavaFX-based desktop frontend application
- **Part 2:** Spring Boot backend REST API server

---

## Prerequisites

- JDK 17 or later installed
- Maven installed
- Internet connection to download dependencies
- (Optional) An IDE like IntelliJ IDEA or VS Code for easier development

---

## Part 1: Running the JavaFX Frontend

1. **Navigate to the project root directory:**

   ```bash
   cd /path/to/coursemanager
   ```

2. **Run the JavaFX application using Maven:**

   ```bash
   mvn javafx:run
   ```

   - This will launch the desktop GUI application.
   - Ensure the Spring Boot backend (Part 2) is running, as the frontend will communicate with it.

---

## Part 2: Running the Spring Boot Backend

1. **Navigate to the project root directory (same as above):**

   ```bash
   cd /path/to/coursemanager
   ```

2. **Run the Spring Boot backend server using Maven:**

   ```bash
   mvn spring-boot:run
   ```

3. **The server will start on port 8080 by default.**

   - Verify by opening [http://localhost:8080/courses](http://localhost:8080/courses) in your browser or using `curl`.

---

## Testing the Backend API (using curl)

- **Get all courses:**

  ```bash
  curl http://localhost:8080/courses
  ```

- **Add a new course:**

  ```bash
  curl -X POST http://localhost:8080/courses \
       -H "Content-Type: application/json" \
       -d '{"name":"SE411","instructor":"Dr. Suliman","credits":3}'
  ```

- **Get a course by ID:**

  ```bash
  curl http://localhost:8080/courses/1
  ```

- **Update a course:**

  ```bash
  curl -X PUT http://localhost:8080/courses/1 \
       -H "Content-Type: application/json" \
       -d '{"name":"SE411 Updated","instructor":"Dr. Suliman","credits":4}'
  ```

- **Delete a course:**

  ```bash
  curl -X DELETE http://localhost:8080/courses/1
  ```

---

## Notes

- The frontend requires the backend to be running for full functionality.
- JavaFX version and Spring Boot version are managed in the `pom.xml`.
- You can build the entire project with:

  ```bash
  mvn clean package
  ```

- Running tests (if any) can be done with:

  ```bash
  mvn test
  ```

---

## Troubleshooting

- If you get errors about missing JavaFX modules, ensure you are running with JDK 17+ and Maven is properly configured.
- Make sure no other service is using port 8080.
- Check logs for error messages in both frontend and backend consoles.

---

## Contact

- Malik Almaghlouth (220110056)
- Mohammad Alsultan (220211275)
- Mohammed Alsafadi (218110698)

---

