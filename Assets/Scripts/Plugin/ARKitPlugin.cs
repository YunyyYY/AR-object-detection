///////////////////////////////////////////////////////////////////////////////
// Modified from: ARKitExample2.cs
// Original by:
// 	   Author: Adam Hegedus
// 	   Contact: adam.hegedus@possible.com
// 	   Copyright © 2018 POSSIBLE CEE. Released under the MIT license.
///////////////////////////////////////////////////////////////////////////////

using System.Linq;
using Vision.Managed;
using UnityEngine;
using UnityEngine.UI;

// ReSharper disable once RedundantUsingDirective
using UnityEngine.XR.iOS;

namespace Plugin
{
	// Combine Vision and ARKit plugins together.
	public class ARKitPlugin : MonoBehaviour 
	{
		// Force Unity to serialize the private variables.
		[SerializeField] private Vision.Managed.Vision _vision;
		[SerializeField] private Text _text;

		private void Awake()
		{
			// set request as classification, and only most confident output
			_vision.SetAndAllocateRequests(VisionRequest.Classification, maxObservations: 1);
		}

		private void OnEnable()
		{
			// Hook up to the completion event of object classification requests
			_vision.OnObjectClassified += Vision_OnObjectClassified;
		}

		private void OnDisable()
		{
			_vision.OnObjectClassified -= Vision_OnObjectClassified;
		}

#if !UNITY_EDITOR && UNITY_IOS
        private void Update()
        {
	        // We only classify a new image if no other vision requests are in progress
            if (_vision.InProgress)
            {
                return;
            }
            
	        // Use the Y plane of the YCbCr texture to render the current camera frame.
            ARTextureHandles handles = UnityARSessionNativeInterface.GetARSessionNativeInterface().GetARVideoTextureHandles();
            if (handles.textureY != System.IntPtr.Zero)
            {
	            // This is the call where we pass in the handle to the metal texture to be analysed
	            _vision.EvaluateBuffer(handles.textureY, ImageDataType.MetalTexture);
            }   
        }
#endif
    
		private void Vision_OnObjectClassified(object sender, ClassificationResultArgs e)
		{
			// Display the top guess for the dominant object on the image
			_text.text = e.observations.First().identifier;
			// Debug.Log(e.observations.First().GetType());
		}
	}
}