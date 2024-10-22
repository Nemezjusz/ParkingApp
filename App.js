import React from 'react';
import { StatusBar } from 'expo-status-bar';
import { NavigationContainer } from '@react-navigation/native'; // Manages app navigation state
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs'; // Creates bottom tab navigation
import Ionicons from 'react-native-vector-icons/Ionicons'; // Icon library

// Import theme and stack navigators
import { theme } from './src/theme/theme';
import HomeStack from './src/navigation/HomeStack';
import ReservationStack from './src/navigation/ReservationStack';
import SettingsStack from './src/navigation/SettingsStack';

// Create the bottom tab navigator
const Tab = createBottomTabNavigator();

export default function App() {
  return (
    <>
      {/* Sets the status bar style to light content */}
      <StatusBar style="light" />
      {/* The navigation container manages the navigation tree */}
      <NavigationContainer>
        {/* Defines the bottom tab navigator */}
        <Tab.Navigator
          initialRouteName="Home"
          screenOptions={({ route }) => ({
            headerShown: false, // Hide the header in the tab navigator
            tabBarIcon: ({ color, size }) => {
              // Define icons for each tab
              let iconName;

              if (route.name === 'Home') {
                iconName = 'home';
              } else if (route.name === 'Reservation') {
                iconName = 'add-circle';
              } else if (route.name === 'Settings') {
                iconName = 'settings'; // Use 'settings' icon
              }

              // Return the appropriate icon
              return <Ionicons name={iconName} size={size} color={color} />;
            },
            // Set tab bar colors and styles
            tabBarActiveTintColor: theme.tabBarActiveTintColor,
            tabBarInactiveTintColor: theme.tabBarInactiveTintColor,
            tabBarStyle: {
              backgroundColor: theme.cardBackgroundColor,
              borderTopColor: 'transparent',
            },
          })}
        >
          {/* Define each tab and its corresponding stack navigator */}
          <Tab.Screen name="Home" component={HomeStack} />
          <Tab.Screen name="Reservation" component={ReservationStack} />
          <Tab.Screen name="Settings" component={SettingsStack} />
        </Tab.Navigator>
      </NavigationContainer>
    </>
  );
}
