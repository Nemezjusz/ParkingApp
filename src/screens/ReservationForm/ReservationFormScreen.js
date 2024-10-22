// src/screens/ReservationForm/ReservationFormScreen.js

import React, { useState } from 'react';
import {
  View,
  Text,
  SafeAreaView,
  TextInput,
  Button,
  TouchableOpacity,
  Alert,
} from 'react-native';
import { styles } from '../../styles/styles';
import { parkingSpots } from '../../data/parkingSpotsData';

function ReservationFormScreen({ navigation }) {
  // State variables for form inputs
  const [spotId, setSpotId] = useState('');
  const [time, setTime] = useState('');

  // Handle form submission
  const handleSubmit = () => {
    // Validate inputs
    if (!spotId || !time) {
      Alert.alert('Error', 'Please fill in all fields.');
      return;
    }

    // Check if spot exists
    const spotExists = parkingSpots.flat().some((spot) => spot.id === spotId);
    if (!spotExists) {
      Alert.alert('Error', 'Spot ID does not exist.');
      return;
    }

    // Implement reservation logic here (e.g., update data, call API)

    Alert.alert('Success', `Reservation made for spot ${spotId} at ${time}`);
    // Navigate back to Home screen or reset form
    setSpotId('');
    setTime('');
    navigation.navigate('Home');
  };

  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.appTitle}>Make a Reservation</Text>
      <View style={styles.formContainer}>
        <Text style={styles.label}>Spot ID:</Text>
        <TextInput
          style={styles.input}
          placeholder="Enter Spot ID (e.g., A1)"
          placeholderTextColor="#ccc"
          value={spotId}
          onChangeText={setSpotId}
        />

        <Text style={styles.label}>Time:</Text>
        <TextInput
          style={styles.input}
          placeholder="Enter Time (e.g., 10:00 - 12:00)"
          placeholderTextColor="#ccc"
          value={time}
          onChangeText={setTime}
        />

        <TouchableOpacity style={styles.button} onPress={handleSubmit}>
          <Text style={styles.buttonText}>Reserve</Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
}

export default ReservationFormScreen;
