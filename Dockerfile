# Use a lightweight Python image
FROM python:3.9

# Set the working directory inside the container
WORKDIR /app/backend

# Copy only requirements first (for better caching)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire project after installing dependencies
COPY . .

# Expose port 8000
EXPOSE 8000

# Use CMD in array format to prevent shell-related issues
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
