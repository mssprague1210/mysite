// This is the entire serverless function.
// It acts as a secure bridge between your website and the weather API.

exports.handler = async function(event, context) {
  // Get the API key from the secure environment variables
  const apiKey = process.env.OPENWEATHERMAP_API_KEY;

  // Get the latitude and longitude from the request sent by the website
  const { lat, lon } = event.queryStringParameters;

  // Construct the API URL
  const apiUrl = `https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&appid=${apiKey}&units=imperial`;

  try {
    // Fetch the weather data from the API
    const response = await fetch(apiUrl);
    const data = await response.json();

    // Send the weather data back to the website
    return {
      statusCode: 200,
      body: JSON.stringify(data),
    };
  } catch (error) {
    // Handle any errors
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Failed to fetch weather data' }),
    };
  }
};
