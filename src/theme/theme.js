// Centralized theme colors and styles

export const theme = {
    primaryColor: '#663399', // Main purple color for headers
    backgroundColor: '#121212', // Dark background for the app
    cardBackgroundColor: '#1e1e1e', // Background for cards and UI elements
    textColor: '#ffffff', // White text color for readability
    availableColor: '#4CAF50', // Green color indicating available spots
    reservedColor: '#FF9800', // Orange color indicating reserved spots
    occupiedColor: '#F44336', // Red color indicating occupied spots
    tabBarActiveTintColor: '#663399', // Active tab icon color
    tabBarInactiveTintColor: 'gray', // Inactive tab icon color
  };
  
  // Header options for stack navigators
  export const headerOptions = {
    headerStyle: {
      backgroundColor: theme.primaryColor, // Set header background color
    },
    headerTintColor: theme.textColor, // Set header text color
    headerTitleStyle: {
      fontWeight: 'bold', // Bold header title
    },
  };