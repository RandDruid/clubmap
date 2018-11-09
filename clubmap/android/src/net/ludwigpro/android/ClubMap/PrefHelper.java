package net.ludwigpro.android.ClubMap;

import java.util.Map;
import java.util.AbstractMap;
import java.util.HashMap;
import java.lang.Throwable;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.util.AndroidException;
import android.util.Log;
import org.qtproject.qt5.android.QtNative;

public class PrefHelper {
        private static final String DATA_CHANGED_MESSAGE = "ClubMap.PrefHelper.changed.";
        private static final String DATA_LOADED_MESSAGE = "ClubMap.PrefHelper.loaded.";

        interface HelperListener extends SharedPreferences.OnSharedPreferenceChangeListener {
                        SharedPreferences preferences();
        }

        static Map<String, HelperListener> _activePrefs = new HashMap<>();

        static void getPrefs(String id) {
            try {
                Context c = QtNative.activity();
                if(c == null)
                        c = QtNative.service();
                registerPrefs(id, c.getSharedPreferences("main", Context.MODE_PRIVATE));
            } catch (Exception ex) {
                Log.e("Not signed app?", ex.toString());
            }
        }

        static void getSharedPrefs(String id, String name) {
            try {
                Context c = QtNative.activity();
                if(c == null)
                        c = QtNative.service();
                registerPrefs(id, c.getSharedPreferences(name, Context.MODE_PRIVATE));
            } catch (Exception ex) {
                Log.e("Not signed app?", ex.toString());
            }
        }

        static void getSharedPrefsPackage(String id, String name, String packageName) {
            try {
                Context c = QtNative.activity();
                if(c == null)
                    c = QtNative.service();
                try {
                    Context cA = c.createPackageContext(packageName, 0);
                    registerPrefs(id, cA.getSharedPreferences(name, Context.MODE_PRIVATE));
                } catch (Exception ex) {
                    Log.e("No data shared", ex.toString());
                }
            } catch (Exception ex) {
                Log.e("Not signed app?", ex.toString());
            }
        }

        static void remPrefs(final String id) {
            try {
                HelperListener listener = _activePrefs.remove(id);
//                if (listener != null) {
                    listener.preferences().unregisterOnSharedPreferenceChangeListener(listener);
//                }
            } catch (Exception ex) {
                Log.e("Error in remPrefs", ex.toString());
            }
        }

        static void save(String id, String key, Object value) {
            try {
                SharedPreferences.Editor prefs = _activePrefs.get(id).preferences().edit();
                if (value.getClass() == Boolean.class) {
                        prefs.putBoolean(key, (Boolean)value);
                } else if (value.getClass() == Float.class) {
                        prefs.putFloat(key, (Float)value);
                } else if (value.getClass() == Integer.class) {
                        prefs.putInt(key, (Integer)value);
                } else if (value.getClass() == Long.class) {
                        prefs.putLong(key, (Long)value);
                } else if (value.getClass() == String.class) {
                        prefs.putString(key, (String)value);
                }
                prefs.apply();
                prefs.commit();
            } catch (Exception ex) {
                Log.e("Error in save", ex.toString());
            }
        }

        static void remove(String id, String key) {
            try {
                SharedPreferences.Editor prefs = _activePrefs.get(id).preferences().edit();
                prefs.remove(key);
                prefs.apply();
                prefs.commit();
            } catch (Exception ex) {
                Log.e("Error in remove", ex.toString());
            }
        }

        private static native void callc(String type, Map message);

        static void registerPrefs(final String id, final SharedPreferences preferences) {
            try {
                HelperListener listener = new HelperListener() {

                        public SharedPreferences preferences() {
                                return preferences;
                        }

                        public void onSharedPreferenceChanged(SharedPreferences prefs, String key) {
                                if(prefs.contains(key)) {
                                        Map<String, ?> data = prefs.getAll();
                                        Map<String, Object> reply = new HashMap();
                                        reply.put("key", key);
                                        reply.put("value", data.get(key));
                                        callc(DATA_CHANGED_MESSAGE + id, reply);
                                } else {
                                        Map<String, Object> reply = new HashMap();
                                        reply.put("key", key);
                                        reply.put("removed", true);
                                        callc(DATA_CHANGED_MESSAGE + id, reply);
                                }
                        }
                };
                _activePrefs.put(id, listener);
                preferences.registerOnSharedPreferenceChangeListener(listener);

                callc(DATA_LOADED_MESSAGE + id, preferences.getAll());
            } catch (Exception ex) {
                Log.e("Can't register helper listener", ex.toString());
            }
        }
}


