///////////////////////////////////////////////////////////////////////////////
// Modified from EventArguments.cs
// Original by:
//     Author: Adam Hegedus
//     Contact: adam.hegedus@possible.com
//     Copyright © 2018 POSSIBLE CEE. Released under the MIT license.
///////////////////////////////////////////////////////////////////////////////

using System;
using System.Collections.Generic;
using Vision.Managed.Bridging;
using UnityEngine;

namespace Vision.Managed
{
    // Carries the results of a successful image classification request.
    public class ClassificationResultArgs : EventArgs
    {
        public readonly VisionClassification[] observations;

        public ClassificationResultArgs(VisionClassification[] observations)
        {
            this.observations = observations;
        }
    }
    
}