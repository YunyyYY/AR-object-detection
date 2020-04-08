///////////////////////////////////////////////////////////////////////////////
// Modified from VisionRequest.cs
// Original by:
//     Author: Adam Hegedus
//     Contact: adam.hegedus@possible.com
//     Copyright © 2018 POSSIBLE CEE. Released under the MIT license.
///////////////////////////////////////////////////////////////////////////////

using System;

namespace Vision.Managed
{
    /// <summary>
    /// Used to specify the type of vision request to perform.
    /// </summary>
    [Flags]
    public enum VisionRequest
    {
        None = 0,
        Classification = 1  // Classify the dominant object on the frame.

    }

//    public static class VisionRequestExtensions
//    {
//        public static bool HasFlag(this VisionRequest request, VisionRequest flag)
//        {
//            return (request & flag) == flag;
//        }
//    }
}

