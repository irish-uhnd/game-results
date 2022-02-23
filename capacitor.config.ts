import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.uhnd.games',
  appName: 'Notre Dame Football Game Results',
  webDir: 'dist',
  bundledWebRuntime: false,
  plugins: {
    SplashScreen: {
      launchAutoHide: false,
      showSpinner: true,
      iosSpinnerStyle: 'large'
    }
  },
  server: {
      cleartext: true
  }
};

export default config;
