package io.github.lukki15.another_network_tool

import android.content.Context
import android.net.DhcpInfo
import android.net.wifi.WifiManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val CHANNEL = "another_network_tool/wifi"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
			when (call.method) {
				"getWifiInfo" -> {
					val wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
					val info = wifiManager.connectionInfo

					val dhcp: DhcpInfo? = try {
						wifiManager.dhcpInfo
					} catch (e: Exception) {
						null
					}

					val routerIp = dhcp?.gateway?.let { ipInt ->
						String.format(
							"%d.%d.%d.%d",
							(ipInt and 0xff),
							(ipInt shr 8 and 0xff),
							(ipInt shr 16 and 0xff),
							(ipInt shr 24 and 0xff)
						)
					}

					val payload: MutableMap<String, Any?> = HashMap()
					payload["routerIp"] = routerIp
					payload["macAddress"] = try { info.macAddress } catch (e: Exception) { null }
					payload["networkId"] = try { info.networkId } catch (e: Exception) { null }
					payload["frequency"] = try { info.frequency } catch (e: Exception) { null }
					payload["channel"] = null
					payload["linkSpeed"] = try { info.linkSpeed } catch (e: Exception) { null }
					payload["signalStrength"] = try { info.rssi } catch (e: Exception) { null }
					payload["isHiddenSSID"] = try { info.isHiddenSSID } catch (e: Exception) { null }

					result.success(payload)
				}
				else -> result.notImplemented()
			}
		}
	}
}
