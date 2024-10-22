import React from 'react';
import { View, Text, SafeAreaView } from 'react-native';
import { styles } from '../../styles/styles';

// SettingsScreen displays app settings
function SettingsScreen() {
  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.appTitle}>Settings Screen</Text>
      {/* Add settings components here */}
    </SafeAreaView>
  );
}

export default SettingsScreen;