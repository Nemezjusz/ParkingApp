import { StyleSheet } from 'react-native';
import { theme } from '../theme/theme';

// Common styles used across the app

export const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.backgroundColor, // App background color
  },
  appTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    textAlign: 'center',
    marginVertical: 10,
    color: theme.textColor,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: '600',
    marginHorizontal: 15,
    marginVertical: 10,
    color: theme.textColor,
  },
  mapContainer: {
    backgroundColor: theme.cardBackgroundColor,
    marginHorizontal: 15,
    padding: 10,
    borderRadius: 8,
    // Shadows for iOS
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.3,
    shadowRadius: 5,
    // Elevation for Android
    elevation: 4,
  },
  parkingSpotRow: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    marginVertical: 5,
  },
  parkingSpot: {
    width: 60,
    height: 100,
    borderRadius: 10,
    justifyContent: 'center',
    alignItems: 'center',
    marginHorizontal: 5,
    borderWidth: 2,
    borderColor: '#fff',
    // Shadows for iOS
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    // Elevation for Android
    elevation: 5,
  },
  parkingSpotLabel: {
    fontWeight: 'bold',
    fontSize: 16,
    color: theme.textColor,
  },
  reservationList: {
    paddingBottom: 100,
  },
  reservationItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 15,
    marginHorizontal: 15,
    marginVertical: 5,
    borderRadius: 10,
    borderWidth: 1,
    borderColor: '#fff',
    // Shadows for iOS
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    // Elevation for Android
    elevation: 5,
  },
  reservationSpot: {
    fontSize: 16,
    fontWeight: 'bold',
    color: theme.textColor,
  },
  reservationStatus: {
    fontSize: 14,
    color: theme.textColor,
  },
  reservationTime: {
    fontSize: 14,
    color: theme.textColor,
  },
  detailText: {
    fontSize: 18,
    marginVertical: 5,
    color: theme.textColor,
    textAlign: 'center',
  },
  // Modal styles
  modalOverlay: {
    flex: 1,
    backgroundColor: '#00000099', // Semi-transparent background
    justifyContent: 'center',
    paddingHorizontal: 40,
  },
  modalView: {
    backgroundColor: theme.cardBackgroundColor,
    borderRadius: 10,
    padding: 20,
    alignItems: 'center',
  },
  modalButton: {
    paddingVertical: 10,
    width: '100%',
  },
  modalButtonText: {
    fontSize: 18,
    color: theme.textColor,
    textAlign: 'center',
  },
  formContainer: {
    paddingHorizontal: 20,
    paddingVertical: 10,
  },
  label: {
    color: theme.textColor,
    fontSize: 16,
    marginVertical: 5,
  },
  input: {
    backgroundColor: theme.cardBackgroundColor,
    color: theme.textColor,
    padding: 10,
    borderRadius: 5,
    marginBottom: 15,
    borderWidth: 1,
    borderColor: '#fff',
  },
  button: {
    backgroundColor: theme.primaryColor,
    paddingVertical: 12,
    borderRadius: 5,
    alignItems: 'center',
    marginVertical: 10,
  },
  buttonText: {
    color: theme.textColor,
    fontSize: 18,
    fontWeight: 'bold',
  },
});