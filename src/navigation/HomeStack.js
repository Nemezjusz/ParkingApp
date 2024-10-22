// src/navigation/HomeStack.js

import React from 'react';
import { createStackNavigator } from '@react-navigation/stack'; // Stack navigator
import { headerOptions } from '../theme/theme'; // Header styles

// Import screens for the Home stack
import ParkingMapScreen from '../screens/Home/ParkingMapScreen';
import ParkingSpotDetailsScreen from '../screens/Home/ParkingSpotDetailsScreen';
import ReservationDetailsScreen from '../screens/Home/ReservationDetailsScreen';
import EditReservationScreen from '../screens/Home/EditReservationScreen';

// Create the stack navigator
const Stack = createStackNavigator();

// Define the Home stack navigator
function HomeStack() {
  return (
    <Stack.Navigator screenOptions={headerOptions}>
      {/* Define each screen in the stack */}
      <Stack.Screen
        name="ParkingMap"
        component={ParkingMapScreen}
        options={{ title: 'IOT App' }}
      />
      <Stack.Screen
        name="ParkingSpotDetails"
        component={ParkingSpotDetailsScreen}
        options={{ title: 'Spot Details' }}
      />
      <Stack.Screen
        name="ReservationDetails"
        component={ReservationDetailsScreen}
        options={{ title: 'Reservation Details' }}
      />
      <Stack.Screen
        name="EditReservation"
        component={EditReservationScreen}
        options={{ title: 'Edit Reservation' }}
      />
    </Stack.Navigator>
  );
}

export default HomeStack;
