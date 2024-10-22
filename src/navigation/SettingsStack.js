import React from 'react';
import { createStackNavigator } from '@react-navigation/stack';
import { headerOptions } from '../theme/theme';

// Import the Settings screen
import SettingsScreen from '../screens/Settings/SettingsScreen';

const Stack = createStackNavigator();

function SettingsStack() {
  return (
    <Stack.Navigator screenOptions={headerOptions}>
      <Stack.Screen
        name="SettingsMain"
        component={SettingsScreen}
        options={{ title: 'Settings' }}
      />
    </Stack.Navigator>
  );
}

export default SettingsStack;