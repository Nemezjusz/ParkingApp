import React from 'react';
import { createStackNavigator } from '@react-navigation/stack';
import { headerOptions } from '../theme/theme';

// Import the ReservationForm screen
import ReservationFormScreen from '../screens/ReservationForm/ReservationFormScreen';

const Stack = createStackNavigator();

function ReservationStack() {
  return (
    <Stack.Navigator screenOptions={headerOptions}>
      <Stack.Screen
        name="ReservationForm"
        component={ReservationFormScreen}
        options={{ title: 'Make a Reservation' }}
      />
    </Stack.Navigator>
  );
}

export default ReservationStack;