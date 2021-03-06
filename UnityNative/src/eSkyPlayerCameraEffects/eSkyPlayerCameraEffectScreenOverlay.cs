﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityStandardAssets.ImageEffects;

public class eSkyPlayerCameraEffectScreenOverlayParam : eSkyPlayerCameraEffectParamBase {
	public int blendMode;
	public float intensity;
	public Texture2D texture;
}


public class eSkyPlayerCameraEffectScreenOverlay : IeSkyPlayerCameraEffectBase {
	protected eSkyPlayerCameraEffectManager m_manager = null;
	protected ScreenOverlay m_screenOverlay = null;

	public eSkyPlayerCameraEffectScreenOverlay(eSkyPlayerCameraEffectManager obj){
		m_manager = obj;
	}

	public void dispose() {
		var type = eSkyPlayerCameraEffectManager.ADDITIONAL_COMPONENT_TYPE.SCREEN_OVERLAY;
		m_screenOverlay.enabled = false;
		m_manager.releaseAdditionalComponent (type);
	}

	public bool start() {
		if (m_screenOverlay != null) {
			return false;
		}
		m_screenOverlay = m_manager.getComponentScreenOverlayBehaviour ();
		return true;
	}
		
	public bool destroy() {
		dispose ();
		return true;
	}

	public bool pause() {
		if (m_screenOverlay == null) {
			return false;
		}

		return true;
	}

	public bool setParam(eSkyPlayerCameraEffectParamBase param) {
		if (m_screenOverlay == null) {
			return false;
		}

		if (param is eSkyPlayerCameraEffectScreenOverlayParam) {
			eSkyPlayerCameraEffectScreenOverlayParam p = param as eSkyPlayerCameraEffectScreenOverlayParam;

			if (System.Enum.IsDefined (typeof(ScreenOverlay.OverlayBlendMode), p.blendMode) == false) {
				return false;
			}

			m_screenOverlay.blendMode = (ScreenOverlay.OverlayBlendMode)p.blendMode;
			m_screenOverlay.intensity = p.intensity;
			m_screenOverlay.texture = p.texture;
		} else {
			return false;
		}

		return true;
	}

	public eSkyPlayerCameraEffectParamBase getParam() {
		if (m_screenOverlay == null) {
			return null;
		}

		eSkyPlayerCameraEffectScreenOverlayParam p = new eSkyPlayerCameraEffectScreenOverlayParam ();
		p.intensity = m_screenOverlay.intensity;
		p.blendMode = (int)m_screenOverlay.blendMode;
		p.texture = m_screenOverlay.texture;

		return p;
	}
}
