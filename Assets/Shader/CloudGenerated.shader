Shader "Shader Graphs/Cloud"
{
    Properties
    {
        _Rotate_Projection("Rotate Projection", Vector, 4) = (0, 0, 0, 0)
        _Property("Property", Float) = 0.5
        _Noise_Speed("Noise Speed", Float) = 1
        _Noise_Remap("Noise Remap", Vector, 4) = (0, 0, 0, 0)
        _Noise_Height("Noise Height", Float) = 1.1
        _Color_Peak("Color Peak", Color) = (0, 0, 0, 0)
        _Color_Valley("Color Valley", Color) = (1, 1, 1, 0)
        _Noise_Edge_1("Noise Edge 1", Float) = 0
        _Noise_Edge_2("Noise Edge 2", Float) = 0
        _Noise_Power("Noise Power", Float) = 0
        _Base_Scale("Base Scale", Float) = 0
        _Base_Speed("Base Speed", Float) = 0
        _Base_Strength("Base Strength", Float) = 0
        _Emission_Strength("Emission Strength", Float) = 0
        _Curvature_Radius("Curvature Radius", Float) = 0
        _Fresnel_Power("Fresnel Power", Float) = 0
        _Fresnel_Opacity("Fresnel Opacity", Float) = 0
        _Fade_Depth("Fade Depth", Float) = 0
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
            "DisableBatching"="False"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull Off
        Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile_fragment _ _SCREEN_SPACE_IRRADIANCE
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ USE_LEGACY_LIGHTMAPS
        #pragma multi_compile _ LIGHTMAP_BICUBIC_SAMPLING
        #pragma multi_compile _ REFLECTION_PROBE_ROTATION
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_ATLAS
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _CLUSTER_LIGHT_LOOP
        #pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHAPREMULTIPLY_ON 1
        #define _ALPHATEST_ON 1
        #define REQUIRE_DEPTH_TEXTURE
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Fog.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
             float4 probeOcclusion;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
             float4 probeOcclusion : INTERP3;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP4;
            #endif
             float4 tangentWS : INTERP5;
             float4 fogFactorAndVertexLight : INTERP6;
             float3 positionWS : INTERP7;
             float3 normalWS : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Rotate_Projection;
        float _Property;
        float _Noise_Speed;
        float4 _Noise_Remap;
        float _Noise_Height;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Curvature_Radius;
        float _Fresnel_Power;
        float _Fresnel_Opacity;
        float _Fade_Depth;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);
            float s, c;
            sincos(Rotation, s, c);
            Axis = normalize(Axis);
            Out = In * c + cross(Axis, In) * s + Axis * dot(Axis, In) * (1 - c);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), ViewDir))), Power);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_c31794c1f855479282ee5da197fed9fd_Out_0_Float = _Noise_Edge_1;
            float _Property_077e847eba5748bb86160070c2deaa64_Out_0_Float = _Noise_Edge_2;
            float4 _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4 = _Rotate_Projection;
            float _Split_b708f28d3c90475d89d47e9a31f41a52_R_1_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[0];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_G_2_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[1];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_B_3_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[2];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_A_4_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[3];
            float3 _RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4.xyz), _Split_b708f28d3c90475d89d47e9a31f41a52_A_4_Float, _RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3);
            float _Property_d539908abf584c3aa4b8fd8280bdbd31_Out_0_Float = _Noise_Speed;
            float _Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_d539908abf584c3aa4b8fd8280bdbd31_Out_0_Float, _Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float);
            float2 _TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float.xx), _TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2);
            float _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float = _Property;
            float _GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2, _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float, _GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float);
            float2 _TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2);
            float _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2, _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float, _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float);
            float _Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float;
            Unity_Add_float(_GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float, _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float, _Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float);
            float _Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float;
            Unity_Divide_float(_Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float, float(2), _Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float);
            float _Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float;
            Unity_Saturate_float(_Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float, _Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float);
            float _Property_eda1028b8e1145128ef9af3133ed5946_Out_0_Float = _Noise_Power;
            float _Power_595cf53127f5490ab915867f6162c276_Out_2_Float;
            Unity_Power_float(_Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float, _Property_eda1028b8e1145128ef9af3133ed5946_Out_0_Float, _Power_595cf53127f5490ab915867f6162c276_Out_2_Float);
            float4 _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4 = _Noise_Remap;
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_R_1_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[0];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_G_2_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[1];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_B_3_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[2];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_A_4_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[3];
            float4 _Combine_3e35a3c53b5242308717f2a942447d7e_RGBA_4_Vector4;
            float3 _Combine_3e35a3c53b5242308717f2a942447d7e_RGB_5_Vector3;
            float2 _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2;
            Unity_Combine_float(_Split_a2df4ccdf77b4b7ea4d10025134553ab_R_1_Float, _Split_a2df4ccdf77b4b7ea4d10025134553ab_G_2_Float, float(0), float(0), _Combine_3e35a3c53b5242308717f2a942447d7e_RGBA_4_Vector4, _Combine_3e35a3c53b5242308717f2a942447d7e_RGB_5_Vector3, _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2);
            float4 _Combine_6707e1830a8b42368404e0ba8aec185c_RGBA_4_Vector4;
            float3 _Combine_6707e1830a8b42368404e0ba8aec185c_RGB_5_Vector3;
            float2 _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2;
            Unity_Combine_float(_Split_a2df4ccdf77b4b7ea4d10025134553ab_B_3_Float, _Split_a2df4ccdf77b4b7ea4d10025134553ab_A_4_Float, float(0), float(0), _Combine_6707e1830a8b42368404e0ba8aec185c_RGBA_4_Vector4, _Combine_6707e1830a8b42368404e0ba8aec185c_RGB_5_Vector3, _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2);
            float _Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float;
            Unity_Remap_float(_Power_595cf53127f5490ab915867f6162c276_Out_2_Float, _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2, _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2, _Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float);
            float _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float;
            Unity_Absolute_float(_Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float, _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float);
            float _Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float;
            Unity_Smoothstep_float(_Property_c31794c1f855479282ee5da197fed9fd_Out_0_Float, _Property_077e847eba5748bb86160070c2deaa64_Out_0_Float, _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float, _Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float);
            float _Property_84ce8b8799384e41913c4d725ccacf18_Out_0_Float = _Base_Speed;
            float _Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_84ce8b8799384e41913c4d725ccacf18_Out_0_Float, _Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float);
            float2 _TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float.xx), _TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2);
            float _Property_1b6de3fe3f0246789b9234d0871589f3_Out_0_Float = _Base_Scale;
            float _GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2, _Property_1b6de3fe3f0246789b9234d0871589f3_Out_0_Float, _GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float);
            float _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float = _Base_Strength;
            float _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float;
            Unity_Multiply_float_float(_GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float, _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float, _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float);
            float _Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float;
            Unity_Add_float(_Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float, _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float, _Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float);
            float _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float;
            Unity_Add_float(float(0), _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float, _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float);
            float _Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float;
            Unity_Divide_float(_Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float, _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float, _Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float);
            float3 _Multiply_add6f8a43114485889343105909217f2_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float.xxx), _Multiply_add6f8a43114485889343105909217f2_Out_2_Vector3);
            float _Property_642c7b99ea2a446a864f6e04b00f09c7_Out_0_Float = _Noise_Height;
            float3 _Multiply_6455f710f60b4a07bbd03b8e981621c1_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_add6f8a43114485889343105909217f2_Out_2_Vector3, (_Property_642c7b99ea2a446a864f6e04b00f09c7_Out_0_Float.xxx), _Multiply_6455f710f60b4a07bbd03b8e981621c1_Out_2_Vector3);
            float3 _Add_86d221c98c2b46c599df05fc07583635_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_6455f710f60b4a07bbd03b8e981621c1_Out_2_Vector3, _Add_86d221c98c2b46c599df05fc07583635_Out_2_Vector3);
            description.Position = _Add_86d221c98c2b46c599df05fc07583635_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_e0d03b59487c437fa1bb9173ce8e8def_Out_0_Vector4 = _Color_Peak;
            float4 _Property_0391558ec0484a35be8ad529889a9447_Out_0_Vector4 = _Color_Valley;
            float _Property_c31794c1f855479282ee5da197fed9fd_Out_0_Float = _Noise_Edge_1;
            float _Property_077e847eba5748bb86160070c2deaa64_Out_0_Float = _Noise_Edge_2;
            float4 _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4 = _Rotate_Projection;
            float _Split_b708f28d3c90475d89d47e9a31f41a52_R_1_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[0];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_G_2_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[1];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_B_3_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[2];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_A_4_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[3];
            float3 _RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4.xyz), _Split_b708f28d3c90475d89d47e9a31f41a52_A_4_Float, _RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3);
            float _Property_d539908abf584c3aa4b8fd8280bdbd31_Out_0_Float = _Noise_Speed;
            float _Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_d539908abf584c3aa4b8fd8280bdbd31_Out_0_Float, _Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float);
            float2 _TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float.xx), _TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2);
            float _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float = _Property;
            float _GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2, _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float, _GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float);
            float2 _TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2);
            float _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2, _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float, _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float);
            float _Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float;
            Unity_Add_float(_GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float, _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float, _Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float);
            float _Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float;
            Unity_Divide_float(_Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float, float(2), _Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float);
            float _Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float;
            Unity_Saturate_float(_Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float, _Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float);
            float _Property_eda1028b8e1145128ef9af3133ed5946_Out_0_Float = _Noise_Power;
            float _Power_595cf53127f5490ab915867f6162c276_Out_2_Float;
            Unity_Power_float(_Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float, _Property_eda1028b8e1145128ef9af3133ed5946_Out_0_Float, _Power_595cf53127f5490ab915867f6162c276_Out_2_Float);
            float4 _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4 = _Noise_Remap;
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_R_1_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[0];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_G_2_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[1];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_B_3_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[2];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_A_4_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[3];
            float4 _Combine_3e35a3c53b5242308717f2a942447d7e_RGBA_4_Vector4;
            float3 _Combine_3e35a3c53b5242308717f2a942447d7e_RGB_5_Vector3;
            float2 _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2;
            Unity_Combine_float(_Split_a2df4ccdf77b4b7ea4d10025134553ab_R_1_Float, _Split_a2df4ccdf77b4b7ea4d10025134553ab_G_2_Float, float(0), float(0), _Combine_3e35a3c53b5242308717f2a942447d7e_RGBA_4_Vector4, _Combine_3e35a3c53b5242308717f2a942447d7e_RGB_5_Vector3, _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2);
            float4 _Combine_6707e1830a8b42368404e0ba8aec185c_RGBA_4_Vector4;
            float3 _Combine_6707e1830a8b42368404e0ba8aec185c_RGB_5_Vector3;
            float2 _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2;
            Unity_Combine_float(_Split_a2df4ccdf77b4b7ea4d10025134553ab_B_3_Float, _Split_a2df4ccdf77b4b7ea4d10025134553ab_A_4_Float, float(0), float(0), _Combine_6707e1830a8b42368404e0ba8aec185c_RGBA_4_Vector4, _Combine_6707e1830a8b42368404e0ba8aec185c_RGB_5_Vector3, _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2);
            float _Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float;
            Unity_Remap_float(_Power_595cf53127f5490ab915867f6162c276_Out_2_Float, _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2, _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2, _Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float);
            float _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float;
            Unity_Absolute_float(_Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float, _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float);
            float _Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float;
            Unity_Smoothstep_float(_Property_c31794c1f855479282ee5da197fed9fd_Out_0_Float, _Property_077e847eba5748bb86160070c2deaa64_Out_0_Float, _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float, _Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float);
            float _Property_84ce8b8799384e41913c4d725ccacf18_Out_0_Float = _Base_Speed;
            float _Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_84ce8b8799384e41913c4d725ccacf18_Out_0_Float, _Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float);
            float2 _TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float.xx), _TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2);
            float _Property_1b6de3fe3f0246789b9234d0871589f3_Out_0_Float = _Base_Scale;
            float _GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2, _Property_1b6de3fe3f0246789b9234d0871589f3_Out_0_Float, _GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float);
            float _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float = _Base_Strength;
            float _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float;
            Unity_Multiply_float_float(_GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float, _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float, _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float);
            float _Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float;
            Unity_Add_float(_Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float, _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float, _Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float);
            float _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float;
            Unity_Add_float(float(0), _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float, _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float);
            float _Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float;
            Unity_Divide_float(_Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float, _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float, _Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float);
            float4 _Lerp_8b39e0711ea040d78445a25812694429_Out_3_Vector4;
            Unity_Lerp_float4(_Property_e0d03b59487c437fa1bb9173ce8e8def_Out_0_Vector4, _Property_0391558ec0484a35be8ad529889a9447_Out_0_Vector4, (_Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float.xxxx), _Lerp_8b39e0711ea040d78445a25812694429_Out_3_Vector4);
            float _Property_00ab0eb814ff416fb477c1ba87ca4d7d_Out_0_Float = _Fresnel_Power;
            float _FresnelEffect_32b3fe63957e43159419f1cfe6bd2fcb_Out_3_Float;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_00ab0eb814ff416fb477c1ba87ca4d7d_Out_0_Float, _FresnelEffect_32b3fe63957e43159419f1cfe6bd2fcb_Out_3_Float);
            float _Multiply_176e613ba30f4d208ddf59298dac4eb0_Out_2_Float;
            Unity_Multiply_float_float(_Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float, _FresnelEffect_32b3fe63957e43159419f1cfe6bd2fcb_Out_3_Float, _Multiply_176e613ba30f4d208ddf59298dac4eb0_Out_2_Float);
            float _Property_f55d0bc6027d404ab1c864ca2a58ff0a_Out_0_Float = _Fresnel_Opacity;
            float _Multiply_741f1176301c4398a41f676c14f3b6a2_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_176e613ba30f4d208ddf59298dac4eb0_Out_2_Float, _Property_f55d0bc6027d404ab1c864ca2a58ff0a_Out_0_Float, _Multiply_741f1176301c4398a41f676c14f3b6a2_Out_2_Float);
            float4 _Add_5a18e1f81a404145a87336aac341f2ef_Out_2_Vector4;
            Unity_Add_float4(_Lerp_8b39e0711ea040d78445a25812694429_Out_3_Vector4, (_Multiply_741f1176301c4398a41f676c14f3b6a2_Out_2_Float.xxxx), _Add_5a18e1f81a404145a87336aac341f2ef_Out_2_Vector4);
            float _Property_0998072383034c728adc22e4f2fb7064_Out_0_Float = _Emission_Strength;
            float4 _Multiply_c76b5472b54b46b2aa96edd7d8450288_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Add_5a18e1f81a404145a87336aac341f2ef_Out_2_Vector4, (_Property_0998072383034c728adc22e4f2fb7064_Out_0_Float.xxxx), _Multiply_c76b5472b54b46b2aa96edd7d8450288_Out_2_Vector4);
            float _SceneDepth_6c648c418b2c4df48061e3694c0deade_Out_1_Float;
            Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_6c648c418b2c4df48061e3694c0deade_Out_1_Float);
            float4 _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_4ca30533313a443cbed9e663a9078bd3_R_1_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[0];
            float _Split_4ca30533313a443cbed9e663a9078bd3_G_2_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[1];
            float _Split_4ca30533313a443cbed9e663a9078bd3_B_3_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[2];
            float _Split_4ca30533313a443cbed9e663a9078bd3_A_4_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[3];
            float _Subtract_8e8c206a123b440d92a6613c55629432_Out_2_Float;
            Unity_Subtract_float(_Split_4ca30533313a443cbed9e663a9078bd3_A_4_Float, float(1), _Subtract_8e8c206a123b440d92a6613c55629432_Out_2_Float);
            float _Subtract_c1a93ffe2989497698a04bc7b908da66_Out_2_Float;
            Unity_Subtract_float(_SceneDepth_6c648c418b2c4df48061e3694c0deade_Out_1_Float, _Subtract_8e8c206a123b440d92a6613c55629432_Out_2_Float, _Subtract_c1a93ffe2989497698a04bc7b908da66_Out_2_Float);
            float _Property_b27fb059166a4fcc8ee3c8de86f584a8_Out_0_Float = _Fade_Depth;
            float _Divide_5c7af79d3663411d88012bd4d64c9f68_Out_2_Float;
            Unity_Divide_float(_Subtract_c1a93ffe2989497698a04bc7b908da66_Out_2_Float, _Property_b27fb059166a4fcc8ee3c8de86f584a8_Out_0_Float, _Divide_5c7af79d3663411d88012bd4d64c9f68_Out_2_Float);
            float _Saturate_4b391c51d8da40f3a6fb4b14f1cba9fd_Out_1_Float;
            Unity_Saturate_float(_Divide_5c7af79d3663411d88012bd4d64c9f68_Out_2_Float, _Saturate_4b391c51d8da40f3a6fb4b14f1cba9fd_Out_1_Float);
            surface.BaseColor = (_Add_5a18e1f81a404145a87336aac341f2ef_Out_2_Vector4.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_c76b5472b54b46b2aa96edd7d8450288_Out_2_Vector4.xyz);
            surface.Metallic = float(0);
            surface.Smoothness = float(0);
            surface.Occlusion = float(1);
            surface.Alpha = _Saturate_4b391c51d8da40f3a6fb4b14f1cba9fd_Out_1_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }
        
        // Render State
        Cull Off
        Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles3 glcore
        #pragma multi_compile_instancing
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_IRRADIANCE
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ USE_LEGACY_LIGHTMAPS
        #pragma multi_compile _ LIGHTMAP_BICUBIC_SAMPLING
        #pragma multi_compile _ REFLECTION_PROBE_ROTATION
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile _ _CLUSTER_LIGHT_LOOP
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHAPREMULTIPLY_ON 1
        #define _ALPHATEST_ON 1
        #define REQUIRE_DEPTH_TEXTURE
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Fog.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
             float4 probeOcclusion;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
             float4 probeOcclusion : INTERP3;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP4;
            #endif
             float4 tangentWS : INTERP5;
             float4 fogFactorAndVertexLight : INTERP6;
             float3 positionWS : INTERP7;
             float3 normalWS : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Rotate_Projection;
        float _Property;
        float _Noise_Speed;
        float4 _Noise_Remap;
        float _Noise_Height;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Curvature_Radius;
        float _Fresnel_Power;
        float _Fresnel_Opacity;
        float _Fade_Depth;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);
            float s, c;
            sincos(Rotation, s, c);
            Axis = normalize(Axis);
            Out = In * c + cross(Axis, In) * s + Axis * dot(Axis, In) * (1 - c);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), ViewDir))), Power);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_c31794c1f855479282ee5da197fed9fd_Out_0_Float = _Noise_Edge_1;
            float _Property_077e847eba5748bb86160070c2deaa64_Out_0_Float = _Noise_Edge_2;
            float4 _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4 = _Rotate_Projection;
            float _Split_b708f28d3c90475d89d47e9a31f41a52_R_1_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[0];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_G_2_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[1];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_B_3_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[2];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_A_4_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[3];
            float3 _RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4.xyz), _Split_b708f28d3c90475d89d47e9a31f41a52_A_4_Float, _RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3);
            float _Property_d539908abf584c3aa4b8fd8280bdbd31_Out_0_Float = _Noise_Speed;
            float _Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_d539908abf584c3aa4b8fd8280bdbd31_Out_0_Float, _Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float);
            float2 _TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float.xx), _TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2);
            float _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float = _Property;
            float _GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2, _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float, _GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float);
            float2 _TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2);
            float _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2, _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float, _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float);
            float _Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float;
            Unity_Add_float(_GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float, _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float, _Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float);
            float _Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float;
            Unity_Divide_float(_Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float, float(2), _Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float);
            float _Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float;
            Unity_Saturate_float(_Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float, _Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float);
            float _Property_eda1028b8e1145128ef9af3133ed5946_Out_0_Float = _Noise_Power;
            float _Power_595cf53127f5490ab915867f6162c276_Out_2_Float;
            Unity_Power_float(_Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float, _Property_eda1028b8e1145128ef9af3133ed5946_Out_0_Float, _Power_595cf53127f5490ab915867f6162c276_Out_2_Float);
            float4 _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4 = _Noise_Remap;
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_R_1_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[0];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_G_2_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[1];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_B_3_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[2];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_A_4_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[3];
            float4 _Combine_3e35a3c53b5242308717f2a942447d7e_RGBA_4_Vector4;
            float3 _Combine_3e35a3c53b5242308717f2a942447d7e_RGB_5_Vector3;
            float2 _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2;
            Unity_Combine_float(_Split_a2df4ccdf77b4b7ea4d10025134553ab_R_1_Float, _Split_a2df4ccdf77b4b7ea4d10025134553ab_G_2_Float, float(0), float(0), _Combine_3e35a3c53b5242308717f2a942447d7e_RGBA_4_Vector4, _Combine_3e35a3c53b5242308717f2a942447d7e_RGB_5_Vector3, _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2);
            float4 _Combine_6707e1830a8b42368404e0ba8aec185c_RGBA_4_Vector4;
            float3 _Combine_6707e1830a8b42368404e0ba8aec185c_RGB_5_Vector3;
            float2 _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2;
            Unity_Combine_float(_Split_a2df4ccdf77b4b7ea4d10025134553ab_B_3_Float, _Split_a2df4ccdf77b4b7ea4d10025134553ab_A_4_Float, float(0), float(0), _Combine_6707e1830a8b42368404e0ba8aec185c_RGBA_4_Vector4, _Combine_6707e1830a8b42368404e0ba8aec185c_RGB_5_Vector3, _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2);
            float _Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float;
            Unity_Remap_float(_Power_595cf53127f5490ab915867f6162c276_Out_2_Float, _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2, _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2, _Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float);
            float _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float;
            Unity_Absolute_float(_Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float, _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float);
            float _Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float;
            Unity_Smoothstep_float(_Property_c31794c1f855479282ee5da197fed9fd_Out_0_Float, _Property_077e847eba5748bb86160070c2deaa64_Out_0_Float, _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float, _Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float);
            float _Property_84ce8b8799384e41913c4d725ccacf18_Out_0_Float = _Base_Speed;
            float _Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_84ce8b8799384e41913c4d725ccacf18_Out_0_Float, _Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float);
            float2 _TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float.xx), _TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2);
            float _Property_1b6de3fe3f0246789b9234d0871589f3_Out_0_Float = _Base_Scale;
            float _GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2, _Property_1b6de3fe3f0246789b9234d0871589f3_Out_0_Float, _GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float);
            float _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float = _Base_Strength;
            float _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float;
            Unity_Multiply_float_float(_GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float, _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float, _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float);
            float _Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float;
            Unity_Add_float(_Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float, _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float, _Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float);
            float _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float;
            Unity_Add_float(float(0), _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float, _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float);
            float _Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float;
            Unity_Divide_float(_Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float, _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float, _Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float);
            float3 _Multiply_add6f8a43114485889343105909217f2_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float.xxx), _Multiply_add6f8a43114485889343105909217f2_Out_2_Vector3);
            float _Property_642c7b99ea2a446a864f6e04b00f09c7_Out_0_Float = _Noise_Height;
            float3 _Multiply_6455f710f60b4a07bbd03b8e981621c1_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_add6f8a43114485889343105909217f2_Out_2_Vector3, (_Property_642c7b99ea2a446a864f6e04b00f09c7_Out_0_Float.xxx), _Multiply_6455f710f60b4a07bbd03b8e981621c1_Out_2_Vector3);
            float3 _Add_86d221c98c2b46c599df05fc07583635_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_6455f710f60b4a07bbd03b8e981621c1_Out_2_Vector3, _Add_86d221c98c2b46c599df05fc07583635_Out_2_Vector3);
            description.Position = _Add_86d221c98c2b46c599df05fc07583635_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_e0d03b59487c437fa1bb9173ce8e8def_Out_0_Vector4 = _Color_Peak;
            float4 _Property_0391558ec0484a35be8ad529889a9447_Out_0_Vector4 = _Color_Valley;
            float _Property_c31794c1f855479282ee5da197fed9fd_Out_0_Float = _Noise_Edge_1;
            float _Property_077e847eba5748bb86160070c2deaa64_Out_0_Float = _Noise_Edge_2;
            float4 _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4 = _Rotate_Projection;
            float _Split_b708f28d3c90475d89d47e9a31f41a52_R_1_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[0];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_G_2_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[1];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_B_3_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[2];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_A_4_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[3];
            float3 _RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4.xyz), _Split_b708f28d3c90475d89d47e9a31f41a52_A_4_Float, _RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3);
            float _Property_d539908abf584c3aa4b8fd8280bdbd31_Out_0_Float = _Noise_Speed;
            float _Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_d539908abf584c3aa4b8fd8280bdbd31_Out_0_Float, _Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float);
            float2 _TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float.xx), _TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2);
            float _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float = _Property;
            float _GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2, _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float, _GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float);
            float2 _TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2);
            float _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2, _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float, _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float);
            float _Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float;
            Unity_Add_float(_GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float, _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float, _Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float);
            float _Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float;
            Unity_Divide_float(_Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float, float(2), _Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float);
            float _Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float;
            Unity_Saturate_float(_Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float, _Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float);
            float _Property_eda1028b8e1145128ef9af3133ed5946_Out_0_Float = _Noise_Power;
            float _Power_595cf53127f5490ab915867f6162c276_Out_2_Float;
            Unity_Power_float(_Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float, _Property_eda1028b8e1145128ef9af3133ed5946_Out_0_Float, _Power_595cf53127f5490ab915867f6162c276_Out_2_Float);
            float4 _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4 = _Noise_Remap;
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_R_1_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[0];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_G_2_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[1];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_B_3_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[2];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_A_4_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[3];
            float4 _Combine_3e35a3c53b5242308717f2a942447d7e_RGBA_4_Vector4;
            float3 _Combine_3e35a3c53b5242308717f2a942447d7e_RGB_5_Vector3;
            float2 _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2;
            Unity_Combine_float(_Split_a2df4ccdf77b4b7ea4d10025134553ab_R_1_Float, _Split_a2df4ccdf77b4b7ea4d10025134553ab_G_2_Float, float(0), float(0), _Combine_3e35a3c53b5242308717f2a942447d7e_RGBA_4_Vector4, _Combine_3e35a3c53b5242308717f2a942447d7e_RGB_5_Vector3, _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2);
            float4 _Combine_6707e1830a8b42368404e0ba8aec185c_RGBA_4_Vector4;
            float3 _Combine_6707e1830a8b42368404e0ba8aec185c_RGB_5_Vector3;
            float2 _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2;
            Unity_Combine_float(_Split_a2df4ccdf77b4b7ea4d10025134553ab_B_3_Float, _Split_a2df4ccdf77b4b7ea4d10025134553ab_A_4_Float, float(0), float(0), _Combine_6707e1830a8b42368404e0ba8aec185c_RGBA_4_Vector4, _Combine_6707e1830a8b42368404e0ba8aec185c_RGB_5_Vector3, _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2);
            float _Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float;
            Unity_Remap_float(_Power_595cf53127f5490ab915867f6162c276_Out_2_Float, _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2, _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2, _Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float);
            float _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float;
            Unity_Absolute_float(_Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float, _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float);
            float _Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float;
            Unity_Smoothstep_float(_Property_c31794c1f855479282ee5da197fed9fd_Out_0_Float, _Property_077e847eba5748bb86160070c2deaa64_Out_0_Float, _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float, _Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float);
            float _Property_84ce8b8799384e41913c4d725ccacf18_Out_0_Float = _Base_Speed;
            float _Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_84ce8b8799384e41913c4d725ccacf18_Out_0_Float, _Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float);
            float2 _TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float.xx), _TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2);
            float _Property_1b6de3fe3f0246789b9234d0871589f3_Out_0_Float = _Base_Scale;
            float _GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2, _Property_1b6de3fe3f0246789b9234d0871589f3_Out_0_Float, _GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float);
            float _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float = _Base_Strength;
            float _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float;
            Unity_Multiply_float_float(_GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float, _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float, _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float);
            float _Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float;
            Unity_Add_float(_Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float, _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float, _Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float);
            float _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float;
            Unity_Add_float(float(0), _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float, _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float);
            float _Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float;
            Unity_Divide_float(_Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float, _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float, _Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float);
            float4 _Lerp_8b39e0711ea040d78445a25812694429_Out_3_Vector4;
            Unity_Lerp_float4(_Property_e0d03b59487c437fa1bb9173ce8e8def_Out_0_Vector4, _Property_0391558ec0484a35be8ad529889a9447_Out_0_Vector4, (_Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float.xxxx), _Lerp_8b39e0711ea040d78445a25812694429_Out_3_Vector4);
            float _Property_00ab0eb814ff416fb477c1ba87ca4d7d_Out_0_Float = _Fresnel_Power;
            float _FresnelEffect_32b3fe63957e43159419f1cfe6bd2fcb_Out_3_Float;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_00ab0eb814ff416fb477c1ba87ca4d7d_Out_0_Float, _FresnelEffect_32b3fe63957e43159419f1cfe6bd2fcb_Out_3_Float);
            float _Multiply_176e613ba30f4d208ddf59298dac4eb0_Out_2_Float;
            Unity_Multiply_float_float(_Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float, _FresnelEffect_32b3fe63957e43159419f1cfe6bd2fcb_Out_3_Float, _Multiply_176e613ba30f4d208ddf59298dac4eb0_Out_2_Float);
            float _Property_f55d0bc6027d404ab1c864ca2a58ff0a_Out_0_Float = _Fresnel_Opacity;
            float _Multiply_741f1176301c4398a41f676c14f3b6a2_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_176e613ba30f4d208ddf59298dac4eb0_Out_2_Float, _Property_f55d0bc6027d404ab1c864ca2a58ff0a_Out_0_Float, _Multiply_741f1176301c4398a41f676c14f3b6a2_Out_2_Float);
            float4 _Add_5a18e1f81a404145a87336aac341f2ef_Out_2_Vector4;
            Unity_Add_float4(_Lerp_8b39e0711ea040d78445a25812694429_Out_3_Vector4, (_Multiply_741f1176301c4398a41f676c14f3b6a2_Out_2_Float.xxxx), _Add_5a18e1f81a404145a87336aac341f2ef_Out_2_Vector4);
            float _Property_0998072383034c728adc22e4f2fb7064_Out_0_Float = _Emission_Strength;
            float4 _Multiply_c76b5472b54b46b2aa96edd7d8450288_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Add_5a18e1f81a404145a87336aac341f2ef_Out_2_Vector4, (_Property_0998072383034c728adc22e4f2fb7064_Out_0_Float.xxxx), _Multiply_c76b5472b54b46b2aa96edd7d8450288_Out_2_Vector4);
            float _SceneDepth_6c648c418b2c4df48061e3694c0deade_Out_1_Float;
            Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_6c648c418b2c4df48061e3694c0deade_Out_1_Float);
            float4 _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_4ca30533313a443cbed9e663a9078bd3_R_1_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[0];
            float _Split_4ca30533313a443cbed9e663a9078bd3_G_2_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[1];
            float _Split_4ca30533313a443cbed9e663a9078bd3_B_3_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[2];
            float _Split_4ca30533313a443cbed9e663a9078bd3_A_4_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[3];
            float _Subtract_8e8c206a123b440d92a6613c55629432_Out_2_Float;
            Unity_Subtract_float(_Split_4ca30533313a443cbed9e663a9078bd3_A_4_Float, float(1), _Subtract_8e8c206a123b440d92a6613c55629432_Out_2_Float);
            float _Subtract_c1a93ffe2989497698a04bc7b908da66_Out_2_Float;
            Unity_Subtract_float(_SceneDepth_6c648c418b2c4df48061e3694c0deade_Out_1_Float, _Subtract_8e8c206a123b440d92a6613c55629432_Out_2_Float, _Subtract_c1a93ffe2989497698a04bc7b908da66_Out_2_Float);
            float _Property_b27fb059166a4fcc8ee3c8de86f584a8_Out_0_Float = _Fade_Depth;
            float _Divide_5c7af79d3663411d88012bd4d64c9f68_Out_2_Float;
            Unity_Divide_float(_Subtract_c1a93ffe2989497698a04bc7b908da66_Out_2_Float, _Property_b27fb059166a4fcc8ee3c8de86f584a8_Out_0_Float, _Divide_5c7af79d3663411d88012bd4d64c9f68_Out_2_Float);
            float _Saturate_4b391c51d8da40f3a6fb4b14f1cba9fd_Out_1_Float;
            Unity_Saturate_float(_Divide_5c7af79d3663411d88012bd4d64c9f68_Out_2_Float, _Saturate_4b391c51d8da40f3a6fb4b14f1cba9fd_Out_1_Float);
            surface.BaseColor = (_Add_5a18e1f81a404145a87336aac341f2ef_Out_2_Vector4.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_c76b5472b54b46b2aa96edd7d8450288_Out_2_Vector4.xyz);
            surface.Metallic = float(0);
            surface.Smoothness = float(0);
            surface.Occlusion = float(1);
            surface.Alpha = _Saturate_4b391c51d8da40f3a6fb4b14f1cba9fd_Out_1_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/GBufferOutput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/GBufferOutputFormat.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Off
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define _ALPHATEST_ON 1
        #define REQUIRE_DEPTH_TEXTURE
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS : INTERP0;
             float3 normalWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Rotate_Projection;
        float _Property;
        float _Noise_Speed;
        float4 _Noise_Remap;
        float _Noise_Height;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Curvature_Radius;
        float _Fresnel_Power;
        float _Fresnel_Opacity;
        float _Fade_Depth;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);
            float s, c;
            sincos(Rotation, s, c);
            Axis = normalize(Axis);
            Out = In * c + cross(Axis, In) * s + Axis * dot(Axis, In) * (1 - c);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_c31794c1f855479282ee5da197fed9fd_Out_0_Float = _Noise_Edge_1;
            float _Property_077e847eba5748bb86160070c2deaa64_Out_0_Float = _Noise_Edge_2;
            float4 _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4 = _Rotate_Projection;
            float _Split_b708f28d3c90475d89d47e9a31f41a52_R_1_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[0];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_G_2_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[1];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_B_3_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[2];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_A_4_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[3];
            float3 _RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4.xyz), _Split_b708f28d3c90475d89d47e9a31f41a52_A_4_Float, _RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3);
            float _Property_d539908abf584c3aa4b8fd8280bdbd31_Out_0_Float = _Noise_Speed;
            float _Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_d539908abf584c3aa4b8fd8280bdbd31_Out_0_Float, _Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float);
            float2 _TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float.xx), _TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2);
            float _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float = _Property;
            float _GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2, _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float, _GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float);
            float2 _TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2);
            float _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2, _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float, _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float);
            float _Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float;
            Unity_Add_float(_GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float, _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float, _Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float);
            float _Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float;
            Unity_Divide_float(_Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float, float(2), _Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float);
            float _Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float;
            Unity_Saturate_float(_Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float, _Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float);
            float _Property_eda1028b8e1145128ef9af3133ed5946_Out_0_Float = _Noise_Power;
            float _Power_595cf53127f5490ab915867f6162c276_Out_2_Float;
            Unity_Power_float(_Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float, _Property_eda1028b8e1145128ef9af3133ed5946_Out_0_Float, _Power_595cf53127f5490ab915867f6162c276_Out_2_Float);
            float4 _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4 = _Noise_Remap;
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_R_1_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[0];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_G_2_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[1];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_B_3_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[2];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_A_4_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[3];
            float4 _Combine_3e35a3c53b5242308717f2a942447d7e_RGBA_4_Vector4;
            float3 _Combine_3e35a3c53b5242308717f2a942447d7e_RGB_5_Vector3;
            float2 _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2;
            Unity_Combine_float(_Split_a2df4ccdf77b4b7ea4d10025134553ab_R_1_Float, _Split_a2df4ccdf77b4b7ea4d10025134553ab_G_2_Float, float(0), float(0), _Combine_3e35a3c53b5242308717f2a942447d7e_RGBA_4_Vector4, _Combine_3e35a3c53b5242308717f2a942447d7e_RGB_5_Vector3, _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2);
            float4 _Combine_6707e1830a8b42368404e0ba8aec185c_RGBA_4_Vector4;
            float3 _Combine_6707e1830a8b42368404e0ba8aec185c_RGB_5_Vector3;
            float2 _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2;
            Unity_Combine_float(_Split_a2df4ccdf77b4b7ea4d10025134553ab_B_3_Float, _Split_a2df4ccdf77b4b7ea4d10025134553ab_A_4_Float, float(0), float(0), _Combine_6707e1830a8b42368404e0ba8aec185c_RGBA_4_Vector4, _Combine_6707e1830a8b42368404e0ba8aec185c_RGB_5_Vector3, _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2);
            float _Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float;
            Unity_Remap_float(_Power_595cf53127f5490ab915867f6162c276_Out_2_Float, _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2, _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2, _Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float);
            float _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float;
            Unity_Absolute_float(_Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float, _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float);
            float _Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float;
            Unity_Smoothstep_float(_Property_c31794c1f855479282ee5da197fed9fd_Out_0_Float, _Property_077e847eba5748bb86160070c2deaa64_Out_0_Float, _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float, _Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float);
            float _Property_84ce8b8799384e41913c4d725ccacf18_Out_0_Float = _Base_Speed;
            float _Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_84ce8b8799384e41913c4d725ccacf18_Out_0_Float, _Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float);
            float2 _TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float.xx), _TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2);
            float _Property_1b6de3fe3f0246789b9234d0871589f3_Out_0_Float = _Base_Scale;
            float _GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2, _Property_1b6de3fe3f0246789b9234d0871589f3_Out_0_Float, _GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float);
            float _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float = _Base_Strength;
            float _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float;
            Unity_Multiply_float_float(_GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float, _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float, _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float);
            float _Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float;
            Unity_Add_float(_Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float, _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float, _Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float);
            float _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float;
            Unity_Add_float(float(0), _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float, _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float);
            float _Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float;
            Unity_Divide_float(_Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float, _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float, _Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float);
            float3 _Multiply_add6f8a43114485889343105909217f2_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float.xxx), _Multiply_add6f8a43114485889343105909217f2_Out_2_Vector3);
            float _Property_642c7b99ea2a446a864f6e04b00f09c7_Out_0_Float = _Noise_Height;
            float3 _Multiply_6455f710f60b4a07bbd03b8e981621c1_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_add6f8a43114485889343105909217f2_Out_2_Vector3, (_Property_642c7b99ea2a446a864f6e04b00f09c7_Out_0_Float.xxx), _Multiply_6455f710f60b4a07bbd03b8e981621c1_Out_2_Vector3);
            float3 _Add_86d221c98c2b46c599df05fc07583635_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_6455f710f60b4a07bbd03b8e981621c1_Out_2_Vector3, _Add_86d221c98c2b46c599df05fc07583635_Out_2_Vector3);
            description.Position = _Add_86d221c98c2b46c599df05fc07583635_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_6c648c418b2c4df48061e3694c0deade_Out_1_Float;
            Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_6c648c418b2c4df48061e3694c0deade_Out_1_Float);
            float4 _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_4ca30533313a443cbed9e663a9078bd3_R_1_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[0];
            float _Split_4ca30533313a443cbed9e663a9078bd3_G_2_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[1];
            float _Split_4ca30533313a443cbed9e663a9078bd3_B_3_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[2];
            float _Split_4ca30533313a443cbed9e663a9078bd3_A_4_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[3];
            float _Subtract_8e8c206a123b440d92a6613c55629432_Out_2_Float;
            Unity_Subtract_float(_Split_4ca30533313a443cbed9e663a9078bd3_A_4_Float, float(1), _Subtract_8e8c206a123b440d92a6613c55629432_Out_2_Float);
            float _Subtract_c1a93ffe2989497698a04bc7b908da66_Out_2_Float;
            Unity_Subtract_float(_SceneDepth_6c648c418b2c4df48061e3694c0deade_Out_1_Float, _Subtract_8e8c206a123b440d92a6613c55629432_Out_2_Float, _Subtract_c1a93ffe2989497698a04bc7b908da66_Out_2_Float);
            float _Property_b27fb059166a4fcc8ee3c8de86f584a8_Out_0_Float = _Fade_Depth;
            float _Divide_5c7af79d3663411d88012bd4d64c9f68_Out_2_Float;
            Unity_Divide_float(_Subtract_c1a93ffe2989497698a04bc7b908da66_Out_2_Float, _Property_b27fb059166a4fcc8ee3c8de86f584a8_Out_0_Float, _Divide_5c7af79d3663411d88012bd4d64c9f68_Out_2_Float);
            float _Saturate_4b391c51d8da40f3a6fb4b14f1cba9fd_Out_1_Float;
            Unity_Saturate_float(_Divide_5c7af79d3663411d88012bd4d64c9f68_Out_2_Float, _Saturate_4b391c51d8da40f3a6fb4b14f1cba9fd_Out_1_Float);
            surface.Alpha = _Saturate_4b391c51d8da40f3a6fb4b14f1cba9fd_Out_1_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "MotionVectors"
            Tags
            {
                "LightMode" = "MotionVectors"
            }
        
        // Render State
        Cull Off
        ZTest LEqual
        ZWrite On
        ColorMask RG
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.5
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_MOTION_VECTORS
        #define _ALPHATEST_ON 1
        #define REQUIRE_DEPTH_TEXTURE
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Rotate_Projection;
        float _Property;
        float _Noise_Speed;
        float4 _Noise_Remap;
        float _Noise_Height;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Curvature_Radius;
        float _Fresnel_Power;
        float _Fresnel_Opacity;
        float _Fade_Depth;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);
            float s, c;
            sincos(Rotation, s, c);
            Axis = normalize(Axis);
            Out = In * c + cross(Axis, In) * s + Axis * dot(Axis, In) * (1 - c);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_c31794c1f855479282ee5da197fed9fd_Out_0_Float = _Noise_Edge_1;
            float _Property_077e847eba5748bb86160070c2deaa64_Out_0_Float = _Noise_Edge_2;
            float4 _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4 = _Rotate_Projection;
            float _Split_b708f28d3c90475d89d47e9a31f41a52_R_1_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[0];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_G_2_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[1];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_B_3_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[2];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_A_4_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[3];
            float3 _RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4.xyz), _Split_b708f28d3c90475d89d47e9a31f41a52_A_4_Float, _RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3);
            float _Property_d539908abf584c3aa4b8fd8280bdbd31_Out_0_Float = _Noise_Speed;
            float _Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_d539908abf584c3aa4b8fd8280bdbd31_Out_0_Float, _Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float);
            float2 _TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float.xx), _TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2);
            float _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float = _Property;
            float _GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2, _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float, _GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float);
            float2 _TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2);
            float _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2, _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float, _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float);
            float _Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float;
            Unity_Add_float(_GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float, _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float, _Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float);
            float _Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float;
            Unity_Divide_float(_Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float, float(2), _Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float);
            float _Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float;
            Unity_Saturate_float(_Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float, _Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float);
            float _Property_eda1028b8e1145128ef9af3133ed5946_Out_0_Float = _Noise_Power;
            float _Power_595cf53127f5490ab915867f6162c276_Out_2_Float;
            Unity_Power_float(_Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float, _Property_eda1028b8e1145128ef9af3133ed5946_Out_0_Float, _Power_595cf53127f5490ab915867f6162c276_Out_2_Float);
            float4 _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4 = _Noise_Remap;
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_R_1_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[0];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_G_2_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[1];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_B_3_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[2];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_A_4_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[3];
            float4 _Combine_3e35a3c53b5242308717f2a942447d7e_RGBA_4_Vector4;
            float3 _Combine_3e35a3c53b5242308717f2a942447d7e_RGB_5_Vector3;
            float2 _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2;
            Unity_Combine_float(_Split_a2df4ccdf77b4b7ea4d10025134553ab_R_1_Float, _Split_a2df4ccdf77b4b7ea4d10025134553ab_G_2_Float, float(0), float(0), _Combine_3e35a3c53b5242308717f2a942447d7e_RGBA_4_Vector4, _Combine_3e35a3c53b5242308717f2a942447d7e_RGB_5_Vector3, _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2);
            float4 _Combine_6707e1830a8b42368404e0ba8aec185c_RGBA_4_Vector4;
            float3 _Combine_6707e1830a8b42368404e0ba8aec185c_RGB_5_Vector3;
            float2 _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2;
            Unity_Combine_float(_Split_a2df4ccdf77b4b7ea4d10025134553ab_B_3_Float, _Split_a2df4ccdf77b4b7ea4d10025134553ab_A_4_Float, float(0), float(0), _Combine_6707e1830a8b42368404e0ba8aec185c_RGBA_4_Vector4, _Combine_6707e1830a8b42368404e0ba8aec185c_RGB_5_Vector3, _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2);
            float _Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float;
            Unity_Remap_float(_Power_595cf53127f5490ab915867f6162c276_Out_2_Float, _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2, _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2, _Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float);
            float _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float;
            Unity_Absolute_float(_Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float, _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float);
            float _Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float;
            Unity_Smoothstep_float(_Property_c31794c1f855479282ee5da197fed9fd_Out_0_Float, _Property_077e847eba5748bb86160070c2deaa64_Out_0_Float, _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float, _Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float);
            float _Property_84ce8b8799384e41913c4d725ccacf18_Out_0_Float = _Base_Speed;
            float _Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_84ce8b8799384e41913c4d725ccacf18_Out_0_Float, _Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float);
            float2 _TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float.xx), _TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2);
            float _Property_1b6de3fe3f0246789b9234d0871589f3_Out_0_Float = _Base_Scale;
            float _GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2, _Property_1b6de3fe3f0246789b9234d0871589f3_Out_0_Float, _GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float);
            float _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float = _Base_Strength;
            float _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float;
            Unity_Multiply_float_float(_GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float, _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float, _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float);
            float _Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float;
            Unity_Add_float(_Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float, _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float, _Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float);
            float _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float;
            Unity_Add_float(float(0), _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float, _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float);
            float _Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float;
            Unity_Divide_float(_Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float, _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float, _Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float);
            float3 _Multiply_add6f8a43114485889343105909217f2_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float.xxx), _Multiply_add6f8a43114485889343105909217f2_Out_2_Vector3);
            float _Property_642c7b99ea2a446a864f6e04b00f09c7_Out_0_Float = _Noise_Height;
            float3 _Multiply_6455f710f60b4a07bbd03b8e981621c1_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_add6f8a43114485889343105909217f2_Out_2_Vector3, (_Property_642c7b99ea2a446a864f6e04b00f09c7_Out_0_Float.xxx), _Multiply_6455f710f60b4a07bbd03b8e981621c1_Out_2_Vector3);
            float3 _Add_86d221c98c2b46c599df05fc07583635_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_6455f710f60b4a07bbd03b8e981621c1_Out_2_Vector3, _Add_86d221c98c2b46c599df05fc07583635_Out_2_Vector3);
            description.Position = _Add_86d221c98c2b46c599df05fc07583635_Out_2_Vector3;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_6c648c418b2c4df48061e3694c0deade_Out_1_Float;
            Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_6c648c418b2c4df48061e3694c0deade_Out_1_Float);
            float4 _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_4ca30533313a443cbed9e663a9078bd3_R_1_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[0];
            float _Split_4ca30533313a443cbed9e663a9078bd3_G_2_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[1];
            float _Split_4ca30533313a443cbed9e663a9078bd3_B_3_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[2];
            float _Split_4ca30533313a443cbed9e663a9078bd3_A_4_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[3];
            float _Subtract_8e8c206a123b440d92a6613c55629432_Out_2_Float;
            Unity_Subtract_float(_Split_4ca30533313a443cbed9e663a9078bd3_A_4_Float, float(1), _Subtract_8e8c206a123b440d92a6613c55629432_Out_2_Float);
            float _Subtract_c1a93ffe2989497698a04bc7b908da66_Out_2_Float;
            Unity_Subtract_float(_SceneDepth_6c648c418b2c4df48061e3694c0deade_Out_1_Float, _Subtract_8e8c206a123b440d92a6613c55629432_Out_2_Float, _Subtract_c1a93ffe2989497698a04bc7b908da66_Out_2_Float);
            float _Property_b27fb059166a4fcc8ee3c8de86f584a8_Out_0_Float = _Fade_Depth;
            float _Divide_5c7af79d3663411d88012bd4d64c9f68_Out_2_Float;
            Unity_Divide_float(_Subtract_c1a93ffe2989497698a04bc7b908da66_Out_2_Float, _Property_b27fb059166a4fcc8ee3c8de86f584a8_Out_0_Float, _Divide_5c7af79d3663411d88012bd4d64c9f68_Out_2_Float);
            float _Saturate_4b391c51d8da40f3a6fb4b14f1cba9fd_Out_1_Float;
            Unity_Saturate_float(_Divide_5c7af79d3663411d88012bd4d64c9f68_Out_2_Float, _Saturate_4b391c51d8da40f3a6fb4b14f1cba9fd_Out_1_Float);
            surface.Alpha = _Saturate_4b391c51d8da40f3a6fb4b14f1cba9fd_Out_1_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/MotionVectorPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }
        
        // Render State
        Cull Off
        ZTest LEqual
        ZWrite On
        ColorMask R
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define _ALPHATEST_ON 1
        #define REQUIRE_DEPTH_TEXTURE
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Rotate_Projection;
        float _Property;
        float _Noise_Speed;
        float4 _Noise_Remap;
        float _Noise_Height;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Curvature_Radius;
        float _Fresnel_Power;
        float _Fresnel_Opacity;
        float _Fade_Depth;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);
            float s, c;
            sincos(Rotation, s, c);
            Axis = normalize(Axis);
            Out = In * c + cross(Axis, In) * s + Axis * dot(Axis, In) * (1 - c);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_c31794c1f855479282ee5da197fed9fd_Out_0_Float = _Noise_Edge_1;
            float _Property_077e847eba5748bb86160070c2deaa64_Out_0_Float = _Noise_Edge_2;
            float4 _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4 = _Rotate_Projection;
            float _Split_b708f28d3c90475d89d47e9a31f41a52_R_1_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[0];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_G_2_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[1];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_B_3_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[2];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_A_4_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[3];
            float3 _RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4.xyz), _Split_b708f28d3c90475d89d47e9a31f41a52_A_4_Float, _RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3);
            float _Property_d539908abf584c3aa4b8fd8280bdbd31_Out_0_Float = _Noise_Speed;
            float _Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_d539908abf584c3aa4b8fd8280bdbd31_Out_0_Float, _Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float);
            float2 _TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float.xx), _TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2);
            float _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float = _Property;
            float _GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2, _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float, _GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float);
            float2 _TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2);
            float _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2, _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float, _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float);
            float _Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float;
            Unity_Add_float(_GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float, _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float, _Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float);
            float _Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float;
            Unity_Divide_float(_Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float, float(2), _Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float);
            float _Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float;
            Unity_Saturate_float(_Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float, _Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float);
            float _Property_eda1028b8e1145128ef9af3133ed5946_Out_0_Float = _Noise_Power;
            float _Power_595cf53127f5490ab915867f6162c276_Out_2_Float;
            Unity_Power_float(_Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float, _Property_eda1028b8e1145128ef9af3133ed5946_Out_0_Float, _Power_595cf53127f5490ab915867f6162c276_Out_2_Float);
            float4 _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4 = _Noise_Remap;
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_R_1_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[0];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_G_2_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[1];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_B_3_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[2];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_A_4_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[3];
            float4 _Combine_3e35a3c53b5242308717f2a942447d7e_RGBA_4_Vector4;
            float3 _Combine_3e35a3c53b5242308717f2a942447d7e_RGB_5_Vector3;
            float2 _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2;
            Unity_Combine_float(_Split_a2df4ccdf77b4b7ea4d10025134553ab_R_1_Float, _Split_a2df4ccdf77b4b7ea4d10025134553ab_G_2_Float, float(0), float(0), _Combine_3e35a3c53b5242308717f2a942447d7e_RGBA_4_Vector4, _Combine_3e35a3c53b5242308717f2a942447d7e_RGB_5_Vector3, _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2);
            float4 _Combine_6707e1830a8b42368404e0ba8aec185c_RGBA_4_Vector4;
            float3 _Combine_6707e1830a8b42368404e0ba8aec185c_RGB_5_Vector3;
            float2 _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2;
            Unity_Combine_float(_Split_a2df4ccdf77b4b7ea4d10025134553ab_B_3_Float, _Split_a2df4ccdf77b4b7ea4d10025134553ab_A_4_Float, float(0), float(0), _Combine_6707e1830a8b42368404e0ba8aec185c_RGBA_4_Vector4, _Combine_6707e1830a8b42368404e0ba8aec185c_RGB_5_Vector3, _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2);
            float _Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float;
            Unity_Remap_float(_Power_595cf53127f5490ab915867f6162c276_Out_2_Float, _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2, _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2, _Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float);
            float _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float;
            Unity_Absolute_float(_Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float, _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float);
            float _Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float;
            Unity_Smoothstep_float(_Property_c31794c1f855479282ee5da197fed9fd_Out_0_Float, _Property_077e847eba5748bb86160070c2deaa64_Out_0_Float, _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float, _Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float);
            float _Property_84ce8b8799384e41913c4d725ccacf18_Out_0_Float = _Base_Speed;
            float _Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_84ce8b8799384e41913c4d725ccacf18_Out_0_Float, _Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float);
            float2 _TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float.xx), _TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2);
            float _Property_1b6de3fe3f0246789b9234d0871589f3_Out_0_Float = _Base_Scale;
            float _GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2, _Property_1b6de3fe3f0246789b9234d0871589f3_Out_0_Float, _GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float);
            float _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float = _Base_Strength;
            float _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float;
            Unity_Multiply_float_float(_GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float, _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float, _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float);
            float _Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float;
            Unity_Add_float(_Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float, _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float, _Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float);
            float _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float;
            Unity_Add_float(float(0), _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float, _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float);
            float _Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float;
            Unity_Divide_float(_Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float, _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float, _Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float);
            float3 _Multiply_add6f8a43114485889343105909217f2_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float.xxx), _Multiply_add6f8a43114485889343105909217f2_Out_2_Vector3);
            float _Property_642c7b99ea2a446a864f6e04b00f09c7_Out_0_Float = _Noise_Height;
            float3 _Multiply_6455f710f60b4a07bbd03b8e981621c1_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_add6f8a43114485889343105909217f2_Out_2_Vector3, (_Property_642c7b99ea2a446a864f6e04b00f09c7_Out_0_Float.xxx), _Multiply_6455f710f60b4a07bbd03b8e981621c1_Out_2_Vector3);
            float3 _Add_86d221c98c2b46c599df05fc07583635_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_6455f710f60b4a07bbd03b8e981621c1_Out_2_Vector3, _Add_86d221c98c2b46c599df05fc07583635_Out_2_Vector3);
            description.Position = _Add_86d221c98c2b46c599df05fc07583635_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_6c648c418b2c4df48061e3694c0deade_Out_1_Float;
            Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_6c648c418b2c4df48061e3694c0deade_Out_1_Float);
            float4 _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_4ca30533313a443cbed9e663a9078bd3_R_1_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[0];
            float _Split_4ca30533313a443cbed9e663a9078bd3_G_2_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[1];
            float _Split_4ca30533313a443cbed9e663a9078bd3_B_3_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[2];
            float _Split_4ca30533313a443cbed9e663a9078bd3_A_4_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[3];
            float _Subtract_8e8c206a123b440d92a6613c55629432_Out_2_Float;
            Unity_Subtract_float(_Split_4ca30533313a443cbed9e663a9078bd3_A_4_Float, float(1), _Subtract_8e8c206a123b440d92a6613c55629432_Out_2_Float);
            float _Subtract_c1a93ffe2989497698a04bc7b908da66_Out_2_Float;
            Unity_Subtract_float(_SceneDepth_6c648c418b2c4df48061e3694c0deade_Out_1_Float, _Subtract_8e8c206a123b440d92a6613c55629432_Out_2_Float, _Subtract_c1a93ffe2989497698a04bc7b908da66_Out_2_Float);
            float _Property_b27fb059166a4fcc8ee3c8de86f584a8_Out_0_Float = _Fade_Depth;
            float _Divide_5c7af79d3663411d88012bd4d64c9f68_Out_2_Float;
            Unity_Divide_float(_Subtract_c1a93ffe2989497698a04bc7b908da66_Out_2_Float, _Property_b27fb059166a4fcc8ee3c8de86f584a8_Out_0_Float, _Divide_5c7af79d3663411d88012bd4d64c9f68_Out_2_Float);
            float _Saturate_4b391c51d8da40f3a6fb4b14f1cba9fd_Out_1_Float;
            Unity_Saturate_float(_Divide_5c7af79d3663411d88012bd4d64c9f68_Out_2_Float, _Saturate_4b391c51d8da40f3a6fb4b14f1cba9fd_Out_1_Float);
            surface.Alpha = _Saturate_4b391c51d8da40f3a6fb4b14f1cba9fd_Out_1_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull Off
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        #define _ALPHATEST_ON 1
        #define REQUIRE_DEPTH_TEXTURE
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 tangentWS : INTERP0;
             float3 positionWS : INTERP1;
             float3 normalWS : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.tangentWS.xyzw = input.tangentWS;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.tangentWS = input.tangentWS.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Rotate_Projection;
        float _Property;
        float _Noise_Speed;
        float4 _Noise_Remap;
        float _Noise_Height;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Curvature_Radius;
        float _Fresnel_Power;
        float _Fresnel_Opacity;
        float _Fade_Depth;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);
            float s, c;
            sincos(Rotation, s, c);
            Axis = normalize(Axis);
            Out = In * c + cross(Axis, In) * s + Axis * dot(Axis, In) * (1 - c);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_c31794c1f855479282ee5da197fed9fd_Out_0_Float = _Noise_Edge_1;
            float _Property_077e847eba5748bb86160070c2deaa64_Out_0_Float = _Noise_Edge_2;
            float4 _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4 = _Rotate_Projection;
            float _Split_b708f28d3c90475d89d47e9a31f41a52_R_1_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[0];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_G_2_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[1];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_B_3_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[2];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_A_4_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[3];
            float3 _RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4.xyz), _Split_b708f28d3c90475d89d47e9a31f41a52_A_4_Float, _RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3);
            float _Property_d539908abf584c3aa4b8fd8280bdbd31_Out_0_Float = _Noise_Speed;
            float _Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_d539908abf584c3aa4b8fd8280bdbd31_Out_0_Float, _Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float);
            float2 _TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float.xx), _TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2);
            float _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float = _Property;
            float _GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2, _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float, _GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float);
            float2 _TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2);
            float _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2, _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float, _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float);
            float _Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float;
            Unity_Add_float(_GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float, _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float, _Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float);
            float _Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float;
            Unity_Divide_float(_Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float, float(2), _Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float);
            float _Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float;
            Unity_Saturate_float(_Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float, _Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float);
            float _Property_eda1028b8e1145128ef9af3133ed5946_Out_0_Float = _Noise_Power;
            float _Power_595cf53127f5490ab915867f6162c276_Out_2_Float;
            Unity_Power_float(_Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float, _Property_eda1028b8e1145128ef9af3133ed5946_Out_0_Float, _Power_595cf53127f5490ab915867f6162c276_Out_2_Float);
            float4 _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4 = _Noise_Remap;
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_R_1_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[0];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_G_2_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[1];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_B_3_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[2];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_A_4_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[3];
            float4 _Combine_3e35a3c53b5242308717f2a942447d7e_RGBA_4_Vector4;
            float3 _Combine_3e35a3c53b5242308717f2a942447d7e_RGB_5_Vector3;
            float2 _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2;
            Unity_Combine_float(_Split_a2df4ccdf77b4b7ea4d10025134553ab_R_1_Float, _Split_a2df4ccdf77b4b7ea4d10025134553ab_G_2_Float, float(0), float(0), _Combine_3e35a3c53b5242308717f2a942447d7e_RGBA_4_Vector4, _Combine_3e35a3c53b5242308717f2a942447d7e_RGB_5_Vector3, _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2);
            float4 _Combine_6707e1830a8b42368404e0ba8aec185c_RGBA_4_Vector4;
            float3 _Combine_6707e1830a8b42368404e0ba8aec185c_RGB_5_Vector3;
            float2 _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2;
            Unity_Combine_float(_Split_a2df4ccdf77b4b7ea4d10025134553ab_B_3_Float, _Split_a2df4ccdf77b4b7ea4d10025134553ab_A_4_Float, float(0), float(0), _Combine_6707e1830a8b42368404e0ba8aec185c_RGBA_4_Vector4, _Combine_6707e1830a8b42368404e0ba8aec185c_RGB_5_Vector3, _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2);
            float _Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float;
            Unity_Remap_float(_Power_595cf53127f5490ab915867f6162c276_Out_2_Float, _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2, _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2, _Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float);
            float _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float;
            Unity_Absolute_float(_Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float, _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float);
            float _Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float;
            Unity_Smoothstep_float(_Property_c31794c1f855479282ee5da197fed9fd_Out_0_Float, _Property_077e847eba5748bb86160070c2deaa64_Out_0_Float, _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float, _Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float);
            float _Property_84ce8b8799384e41913c4d725ccacf18_Out_0_Float = _Base_Speed;
            float _Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_84ce8b8799384e41913c4d725ccacf18_Out_0_Float, _Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float);
            float2 _TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float.xx), _TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2);
            float _Property_1b6de3fe3f0246789b9234d0871589f3_Out_0_Float = _Base_Scale;
            float _GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2, _Property_1b6de3fe3f0246789b9234d0871589f3_Out_0_Float, _GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float);
            float _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float = _Base_Strength;
            float _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float;
            Unity_Multiply_float_float(_GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float, _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float, _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float);
            float _Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float;
            Unity_Add_float(_Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float, _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float, _Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float);
            float _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float;
            Unity_Add_float(float(0), _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float, _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float);
            float _Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float;
            Unity_Divide_float(_Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float, _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float, _Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float);
            float3 _Multiply_add6f8a43114485889343105909217f2_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float.xxx), _Multiply_add6f8a43114485889343105909217f2_Out_2_Vector3);
            float _Property_642c7b99ea2a446a864f6e04b00f09c7_Out_0_Float = _Noise_Height;
            float3 _Multiply_6455f710f60b4a07bbd03b8e981621c1_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_add6f8a43114485889343105909217f2_Out_2_Vector3, (_Property_642c7b99ea2a446a864f6e04b00f09c7_Out_0_Float.xxx), _Multiply_6455f710f60b4a07bbd03b8e981621c1_Out_2_Vector3);
            float3 _Add_86d221c98c2b46c599df05fc07583635_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_6455f710f60b4a07bbd03b8e981621c1_Out_2_Vector3, _Add_86d221c98c2b46c599df05fc07583635_Out_2_Vector3);
            description.Position = _Add_86d221c98c2b46c599df05fc07583635_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_6c648c418b2c4df48061e3694c0deade_Out_1_Float;
            Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_6c648c418b2c4df48061e3694c0deade_Out_1_Float);
            float4 _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_4ca30533313a443cbed9e663a9078bd3_R_1_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[0];
            float _Split_4ca30533313a443cbed9e663a9078bd3_G_2_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[1];
            float _Split_4ca30533313a443cbed9e663a9078bd3_B_3_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[2];
            float _Split_4ca30533313a443cbed9e663a9078bd3_A_4_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[3];
            float _Subtract_8e8c206a123b440d92a6613c55629432_Out_2_Float;
            Unity_Subtract_float(_Split_4ca30533313a443cbed9e663a9078bd3_A_4_Float, float(1), _Subtract_8e8c206a123b440d92a6613c55629432_Out_2_Float);
            float _Subtract_c1a93ffe2989497698a04bc7b908da66_Out_2_Float;
            Unity_Subtract_float(_SceneDepth_6c648c418b2c4df48061e3694c0deade_Out_1_Float, _Subtract_8e8c206a123b440d92a6613c55629432_Out_2_Float, _Subtract_c1a93ffe2989497698a04bc7b908da66_Out_2_Float);
            float _Property_b27fb059166a4fcc8ee3c8de86f584a8_Out_0_Float = _Fade_Depth;
            float _Divide_5c7af79d3663411d88012bd4d64c9f68_Out_2_Float;
            Unity_Divide_float(_Subtract_c1a93ffe2989497698a04bc7b908da66_Out_2_Float, _Property_b27fb059166a4fcc8ee3c8de86f584a8_Out_0_Float, _Divide_5c7af79d3663411d88012bd4d64c9f68_Out_2_Float);
            float _Saturate_4b391c51d8da40f3a6fb4b14f1cba9fd_Out_1_Float;
            Unity_Saturate_float(_Divide_5c7af79d3663411d88012bd4d64c9f68_Out_2_Float, _Saturate_4b391c51d8da40f3a6fb4b14f1cba9fd_Out_1_Float);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _Saturate_4b391c51d8da40f3a6fb4b14f1cba9fd_Out_1_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define ATTRIBUTES_NEED_INSTANCEID
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        #define _ALPHATEST_ON 1
        #define REQUIRE_DEPTH_TEXTURE
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float4 texCoord1 : INTERP1;
             float4 texCoord2 : INTERP2;
             float3 positionWS : INTERP3;
             float3 normalWS : INTERP4;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.texCoord2.xyzw = input.texCoord2;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.texCoord2 = input.texCoord2.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Rotate_Projection;
        float _Property;
        float _Noise_Speed;
        float4 _Noise_Remap;
        float _Noise_Height;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Curvature_Radius;
        float _Fresnel_Power;
        float _Fresnel_Opacity;
        float _Fade_Depth;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);
            float s, c;
            sincos(Rotation, s, c);
            Axis = normalize(Axis);
            Out = In * c + cross(Axis, In) * s + Axis * dot(Axis, In) * (1 - c);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), ViewDir))), Power);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_c31794c1f855479282ee5da197fed9fd_Out_0_Float = _Noise_Edge_1;
            float _Property_077e847eba5748bb86160070c2deaa64_Out_0_Float = _Noise_Edge_2;
            float4 _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4 = _Rotate_Projection;
            float _Split_b708f28d3c90475d89d47e9a31f41a52_R_1_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[0];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_G_2_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[1];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_B_3_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[2];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_A_4_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[3];
            float3 _RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4.xyz), _Split_b708f28d3c90475d89d47e9a31f41a52_A_4_Float, _RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3);
            float _Property_d539908abf584c3aa4b8fd8280bdbd31_Out_0_Float = _Noise_Speed;
            float _Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_d539908abf584c3aa4b8fd8280bdbd31_Out_0_Float, _Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float);
            float2 _TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float.xx), _TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2);
            float _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float = _Property;
            float _GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2, _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float, _GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float);
            float2 _TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2);
            float _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2, _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float, _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float);
            float _Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float;
            Unity_Add_float(_GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float, _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float, _Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float);
            float _Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float;
            Unity_Divide_float(_Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float, float(2), _Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float);
            float _Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float;
            Unity_Saturate_float(_Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float, _Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float);
            float _Property_eda1028b8e1145128ef9af3133ed5946_Out_0_Float = _Noise_Power;
            float _Power_595cf53127f5490ab915867f6162c276_Out_2_Float;
            Unity_Power_float(_Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float, _Property_eda1028b8e1145128ef9af3133ed5946_Out_0_Float, _Power_595cf53127f5490ab915867f6162c276_Out_2_Float);
            float4 _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4 = _Noise_Remap;
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_R_1_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[0];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_G_2_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[1];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_B_3_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[2];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_A_4_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[3];
            float4 _Combine_3e35a3c53b5242308717f2a942447d7e_RGBA_4_Vector4;
            float3 _Combine_3e35a3c53b5242308717f2a942447d7e_RGB_5_Vector3;
            float2 _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2;
            Unity_Combine_float(_Split_a2df4ccdf77b4b7ea4d10025134553ab_R_1_Float, _Split_a2df4ccdf77b4b7ea4d10025134553ab_G_2_Float, float(0), float(0), _Combine_3e35a3c53b5242308717f2a942447d7e_RGBA_4_Vector4, _Combine_3e35a3c53b5242308717f2a942447d7e_RGB_5_Vector3, _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2);
            float4 _Combine_6707e1830a8b42368404e0ba8aec185c_RGBA_4_Vector4;
            float3 _Combine_6707e1830a8b42368404e0ba8aec185c_RGB_5_Vector3;
            float2 _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2;
            Unity_Combine_float(_Split_a2df4ccdf77b4b7ea4d10025134553ab_B_3_Float, _Split_a2df4ccdf77b4b7ea4d10025134553ab_A_4_Float, float(0), float(0), _Combine_6707e1830a8b42368404e0ba8aec185c_RGBA_4_Vector4, _Combine_6707e1830a8b42368404e0ba8aec185c_RGB_5_Vector3, _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2);
            float _Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float;
            Unity_Remap_float(_Power_595cf53127f5490ab915867f6162c276_Out_2_Float, _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2, _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2, _Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float);
            float _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float;
            Unity_Absolute_float(_Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float, _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float);
            float _Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float;
            Unity_Smoothstep_float(_Property_c31794c1f855479282ee5da197fed9fd_Out_0_Float, _Property_077e847eba5748bb86160070c2deaa64_Out_0_Float, _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float, _Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float);
            float _Property_84ce8b8799384e41913c4d725ccacf18_Out_0_Float = _Base_Speed;
            float _Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_84ce8b8799384e41913c4d725ccacf18_Out_0_Float, _Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float);
            float2 _TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float.xx), _TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2);
            float _Property_1b6de3fe3f0246789b9234d0871589f3_Out_0_Float = _Base_Scale;
            float _GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2, _Property_1b6de3fe3f0246789b9234d0871589f3_Out_0_Float, _GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float);
            float _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float = _Base_Strength;
            float _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float;
            Unity_Multiply_float_float(_GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float, _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float, _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float);
            float _Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float;
            Unity_Add_float(_Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float, _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float, _Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float);
            float _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float;
            Unity_Add_float(float(0), _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float, _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float);
            float _Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float;
            Unity_Divide_float(_Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float, _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float, _Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float);
            float3 _Multiply_add6f8a43114485889343105909217f2_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float.xxx), _Multiply_add6f8a43114485889343105909217f2_Out_2_Vector3);
            float _Property_642c7b99ea2a446a864f6e04b00f09c7_Out_0_Float = _Noise_Height;
            float3 _Multiply_6455f710f60b4a07bbd03b8e981621c1_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_add6f8a43114485889343105909217f2_Out_2_Vector3, (_Property_642c7b99ea2a446a864f6e04b00f09c7_Out_0_Float.xxx), _Multiply_6455f710f60b4a07bbd03b8e981621c1_Out_2_Vector3);
            float3 _Add_86d221c98c2b46c599df05fc07583635_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_6455f710f60b4a07bbd03b8e981621c1_Out_2_Vector3, _Add_86d221c98c2b46c599df05fc07583635_Out_2_Vector3);
            description.Position = _Add_86d221c98c2b46c599df05fc07583635_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_e0d03b59487c437fa1bb9173ce8e8def_Out_0_Vector4 = _Color_Peak;
            float4 _Property_0391558ec0484a35be8ad529889a9447_Out_0_Vector4 = _Color_Valley;
            float _Property_c31794c1f855479282ee5da197fed9fd_Out_0_Float = _Noise_Edge_1;
            float _Property_077e847eba5748bb86160070c2deaa64_Out_0_Float = _Noise_Edge_2;
            float4 _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4 = _Rotate_Projection;
            float _Split_b708f28d3c90475d89d47e9a31f41a52_R_1_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[0];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_G_2_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[1];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_B_3_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[2];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_A_4_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[3];
            float3 _RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4.xyz), _Split_b708f28d3c90475d89d47e9a31f41a52_A_4_Float, _RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3);
            float _Property_d539908abf584c3aa4b8fd8280bdbd31_Out_0_Float = _Noise_Speed;
            float _Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_d539908abf584c3aa4b8fd8280bdbd31_Out_0_Float, _Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float);
            float2 _TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float.xx), _TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2);
            float _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float = _Property;
            float _GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2, _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float, _GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float);
            float2 _TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2);
            float _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2, _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float, _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float);
            float _Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float;
            Unity_Add_float(_GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float, _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float, _Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float);
            float _Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float;
            Unity_Divide_float(_Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float, float(2), _Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float);
            float _Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float;
            Unity_Saturate_float(_Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float, _Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float);
            float _Property_eda1028b8e1145128ef9af3133ed5946_Out_0_Float = _Noise_Power;
            float _Power_595cf53127f5490ab915867f6162c276_Out_2_Float;
            Unity_Power_float(_Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float, _Property_eda1028b8e1145128ef9af3133ed5946_Out_0_Float, _Power_595cf53127f5490ab915867f6162c276_Out_2_Float);
            float4 _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4 = _Noise_Remap;
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_R_1_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[0];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_G_2_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[1];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_B_3_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[2];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_A_4_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[3];
            float4 _Combine_3e35a3c53b5242308717f2a942447d7e_RGBA_4_Vector4;
            float3 _Combine_3e35a3c53b5242308717f2a942447d7e_RGB_5_Vector3;
            float2 _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2;
            Unity_Combine_float(_Split_a2df4ccdf77b4b7ea4d10025134553ab_R_1_Float, _Split_a2df4ccdf77b4b7ea4d10025134553ab_G_2_Float, float(0), float(0), _Combine_3e35a3c53b5242308717f2a942447d7e_RGBA_4_Vector4, _Combine_3e35a3c53b5242308717f2a942447d7e_RGB_5_Vector3, _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2);
            float4 _Combine_6707e1830a8b42368404e0ba8aec185c_RGBA_4_Vector4;
            float3 _Combine_6707e1830a8b42368404e0ba8aec185c_RGB_5_Vector3;
            float2 _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2;
            Unity_Combine_float(_Split_a2df4ccdf77b4b7ea4d10025134553ab_B_3_Float, _Split_a2df4ccdf77b4b7ea4d10025134553ab_A_4_Float, float(0), float(0), _Combine_6707e1830a8b42368404e0ba8aec185c_RGBA_4_Vector4, _Combine_6707e1830a8b42368404e0ba8aec185c_RGB_5_Vector3, _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2);
            float _Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float;
            Unity_Remap_float(_Power_595cf53127f5490ab915867f6162c276_Out_2_Float, _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2, _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2, _Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float);
            float _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float;
            Unity_Absolute_float(_Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float, _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float);
            float _Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float;
            Unity_Smoothstep_float(_Property_c31794c1f855479282ee5da197fed9fd_Out_0_Float, _Property_077e847eba5748bb86160070c2deaa64_Out_0_Float, _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float, _Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float);
            float _Property_84ce8b8799384e41913c4d725ccacf18_Out_0_Float = _Base_Speed;
            float _Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_84ce8b8799384e41913c4d725ccacf18_Out_0_Float, _Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float);
            float2 _TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float.xx), _TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2);
            float _Property_1b6de3fe3f0246789b9234d0871589f3_Out_0_Float = _Base_Scale;
            float _GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2, _Property_1b6de3fe3f0246789b9234d0871589f3_Out_0_Float, _GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float);
            float _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float = _Base_Strength;
            float _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float;
            Unity_Multiply_float_float(_GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float, _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float, _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float);
            float _Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float;
            Unity_Add_float(_Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float, _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float, _Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float);
            float _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float;
            Unity_Add_float(float(0), _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float, _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float);
            float _Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float;
            Unity_Divide_float(_Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float, _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float, _Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float);
            float4 _Lerp_8b39e0711ea040d78445a25812694429_Out_3_Vector4;
            Unity_Lerp_float4(_Property_e0d03b59487c437fa1bb9173ce8e8def_Out_0_Vector4, _Property_0391558ec0484a35be8ad529889a9447_Out_0_Vector4, (_Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float.xxxx), _Lerp_8b39e0711ea040d78445a25812694429_Out_3_Vector4);
            float _Property_00ab0eb814ff416fb477c1ba87ca4d7d_Out_0_Float = _Fresnel_Power;
            float _FresnelEffect_32b3fe63957e43159419f1cfe6bd2fcb_Out_3_Float;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_00ab0eb814ff416fb477c1ba87ca4d7d_Out_0_Float, _FresnelEffect_32b3fe63957e43159419f1cfe6bd2fcb_Out_3_Float);
            float _Multiply_176e613ba30f4d208ddf59298dac4eb0_Out_2_Float;
            Unity_Multiply_float_float(_Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float, _FresnelEffect_32b3fe63957e43159419f1cfe6bd2fcb_Out_3_Float, _Multiply_176e613ba30f4d208ddf59298dac4eb0_Out_2_Float);
            float _Property_f55d0bc6027d404ab1c864ca2a58ff0a_Out_0_Float = _Fresnel_Opacity;
            float _Multiply_741f1176301c4398a41f676c14f3b6a2_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_176e613ba30f4d208ddf59298dac4eb0_Out_2_Float, _Property_f55d0bc6027d404ab1c864ca2a58ff0a_Out_0_Float, _Multiply_741f1176301c4398a41f676c14f3b6a2_Out_2_Float);
            float4 _Add_5a18e1f81a404145a87336aac341f2ef_Out_2_Vector4;
            Unity_Add_float4(_Lerp_8b39e0711ea040d78445a25812694429_Out_3_Vector4, (_Multiply_741f1176301c4398a41f676c14f3b6a2_Out_2_Float.xxxx), _Add_5a18e1f81a404145a87336aac341f2ef_Out_2_Vector4);
            float _Property_0998072383034c728adc22e4f2fb7064_Out_0_Float = _Emission_Strength;
            float4 _Multiply_c76b5472b54b46b2aa96edd7d8450288_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Add_5a18e1f81a404145a87336aac341f2ef_Out_2_Vector4, (_Property_0998072383034c728adc22e4f2fb7064_Out_0_Float.xxxx), _Multiply_c76b5472b54b46b2aa96edd7d8450288_Out_2_Vector4);
            float _SceneDepth_6c648c418b2c4df48061e3694c0deade_Out_1_Float;
            Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_6c648c418b2c4df48061e3694c0deade_Out_1_Float);
            float4 _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_4ca30533313a443cbed9e663a9078bd3_R_1_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[0];
            float _Split_4ca30533313a443cbed9e663a9078bd3_G_2_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[1];
            float _Split_4ca30533313a443cbed9e663a9078bd3_B_3_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[2];
            float _Split_4ca30533313a443cbed9e663a9078bd3_A_4_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[3];
            float _Subtract_8e8c206a123b440d92a6613c55629432_Out_2_Float;
            Unity_Subtract_float(_Split_4ca30533313a443cbed9e663a9078bd3_A_4_Float, float(1), _Subtract_8e8c206a123b440d92a6613c55629432_Out_2_Float);
            float _Subtract_c1a93ffe2989497698a04bc7b908da66_Out_2_Float;
            Unity_Subtract_float(_SceneDepth_6c648c418b2c4df48061e3694c0deade_Out_1_Float, _Subtract_8e8c206a123b440d92a6613c55629432_Out_2_Float, _Subtract_c1a93ffe2989497698a04bc7b908da66_Out_2_Float);
            float _Property_b27fb059166a4fcc8ee3c8de86f584a8_Out_0_Float = _Fade_Depth;
            float _Divide_5c7af79d3663411d88012bd4d64c9f68_Out_2_Float;
            Unity_Divide_float(_Subtract_c1a93ffe2989497698a04bc7b908da66_Out_2_Float, _Property_b27fb059166a4fcc8ee3c8de86f584a8_Out_0_Float, _Divide_5c7af79d3663411d88012bd4d64c9f68_Out_2_Float);
            float _Saturate_4b391c51d8da40f3a6fb4b14f1cba9fd_Out_1_Float;
            Unity_Saturate_float(_Divide_5c7af79d3663411d88012bd4d64c9f68_Out_2_Float, _Saturate_4b391c51d8da40f3a6fb4b14f1cba9fd_Out_1_Float);
            surface.BaseColor = (_Add_5a18e1f81a404145a87336aac341f2ef_Out_2_Vector4.xyz);
            surface.Emission = (_Multiply_c76b5472b54b46b2aa96edd7d8450288_Out_2_Vector4.xyz);
            surface.Alpha = _Saturate_4b391c51d8da40f3a6fb4b14f1cba9fd_Out_1_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        #define REQUIRE_DEPTH_TEXTURE
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Rotate_Projection;
        float _Property;
        float _Noise_Speed;
        float4 _Noise_Remap;
        float _Noise_Height;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Curvature_Radius;
        float _Fresnel_Power;
        float _Fresnel_Opacity;
        float _Fade_Depth;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);
            float s, c;
            sincos(Rotation, s, c);
            Axis = normalize(Axis);
            Out = In * c + cross(Axis, In) * s + Axis * dot(Axis, In) * (1 - c);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_c31794c1f855479282ee5da197fed9fd_Out_0_Float = _Noise_Edge_1;
            float _Property_077e847eba5748bb86160070c2deaa64_Out_0_Float = _Noise_Edge_2;
            float4 _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4 = _Rotate_Projection;
            float _Split_b708f28d3c90475d89d47e9a31f41a52_R_1_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[0];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_G_2_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[1];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_B_3_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[2];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_A_4_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[3];
            float3 _RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4.xyz), _Split_b708f28d3c90475d89d47e9a31f41a52_A_4_Float, _RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3);
            float _Property_d539908abf584c3aa4b8fd8280bdbd31_Out_0_Float = _Noise_Speed;
            float _Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_d539908abf584c3aa4b8fd8280bdbd31_Out_0_Float, _Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float);
            float2 _TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float.xx), _TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2);
            float _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float = _Property;
            float _GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2, _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float, _GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float);
            float2 _TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2);
            float _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2, _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float, _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float);
            float _Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float;
            Unity_Add_float(_GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float, _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float, _Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float);
            float _Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float;
            Unity_Divide_float(_Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float, float(2), _Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float);
            float _Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float;
            Unity_Saturate_float(_Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float, _Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float);
            float _Property_eda1028b8e1145128ef9af3133ed5946_Out_0_Float = _Noise_Power;
            float _Power_595cf53127f5490ab915867f6162c276_Out_2_Float;
            Unity_Power_float(_Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float, _Property_eda1028b8e1145128ef9af3133ed5946_Out_0_Float, _Power_595cf53127f5490ab915867f6162c276_Out_2_Float);
            float4 _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4 = _Noise_Remap;
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_R_1_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[0];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_G_2_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[1];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_B_3_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[2];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_A_4_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[3];
            float4 _Combine_3e35a3c53b5242308717f2a942447d7e_RGBA_4_Vector4;
            float3 _Combine_3e35a3c53b5242308717f2a942447d7e_RGB_5_Vector3;
            float2 _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2;
            Unity_Combine_float(_Split_a2df4ccdf77b4b7ea4d10025134553ab_R_1_Float, _Split_a2df4ccdf77b4b7ea4d10025134553ab_G_2_Float, float(0), float(0), _Combine_3e35a3c53b5242308717f2a942447d7e_RGBA_4_Vector4, _Combine_3e35a3c53b5242308717f2a942447d7e_RGB_5_Vector3, _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2);
            float4 _Combine_6707e1830a8b42368404e0ba8aec185c_RGBA_4_Vector4;
            float3 _Combine_6707e1830a8b42368404e0ba8aec185c_RGB_5_Vector3;
            float2 _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2;
            Unity_Combine_float(_Split_a2df4ccdf77b4b7ea4d10025134553ab_B_3_Float, _Split_a2df4ccdf77b4b7ea4d10025134553ab_A_4_Float, float(0), float(0), _Combine_6707e1830a8b42368404e0ba8aec185c_RGBA_4_Vector4, _Combine_6707e1830a8b42368404e0ba8aec185c_RGB_5_Vector3, _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2);
            float _Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float;
            Unity_Remap_float(_Power_595cf53127f5490ab915867f6162c276_Out_2_Float, _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2, _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2, _Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float);
            float _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float;
            Unity_Absolute_float(_Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float, _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float);
            float _Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float;
            Unity_Smoothstep_float(_Property_c31794c1f855479282ee5da197fed9fd_Out_0_Float, _Property_077e847eba5748bb86160070c2deaa64_Out_0_Float, _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float, _Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float);
            float _Property_84ce8b8799384e41913c4d725ccacf18_Out_0_Float = _Base_Speed;
            float _Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_84ce8b8799384e41913c4d725ccacf18_Out_0_Float, _Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float);
            float2 _TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float.xx), _TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2);
            float _Property_1b6de3fe3f0246789b9234d0871589f3_Out_0_Float = _Base_Scale;
            float _GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2, _Property_1b6de3fe3f0246789b9234d0871589f3_Out_0_Float, _GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float);
            float _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float = _Base_Strength;
            float _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float;
            Unity_Multiply_float_float(_GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float, _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float, _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float);
            float _Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float;
            Unity_Add_float(_Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float, _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float, _Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float);
            float _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float;
            Unity_Add_float(float(0), _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float, _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float);
            float _Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float;
            Unity_Divide_float(_Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float, _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float, _Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float);
            float3 _Multiply_add6f8a43114485889343105909217f2_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float.xxx), _Multiply_add6f8a43114485889343105909217f2_Out_2_Vector3);
            float _Property_642c7b99ea2a446a864f6e04b00f09c7_Out_0_Float = _Noise_Height;
            float3 _Multiply_6455f710f60b4a07bbd03b8e981621c1_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_add6f8a43114485889343105909217f2_Out_2_Vector3, (_Property_642c7b99ea2a446a864f6e04b00f09c7_Out_0_Float.xxx), _Multiply_6455f710f60b4a07bbd03b8e981621c1_Out_2_Vector3);
            float3 _Add_86d221c98c2b46c599df05fc07583635_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_6455f710f60b4a07bbd03b8e981621c1_Out_2_Vector3, _Add_86d221c98c2b46c599df05fc07583635_Out_2_Vector3);
            description.Position = _Add_86d221c98c2b46c599df05fc07583635_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_6c648c418b2c4df48061e3694c0deade_Out_1_Float;
            Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_6c648c418b2c4df48061e3694c0deade_Out_1_Float);
            float4 _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_4ca30533313a443cbed9e663a9078bd3_R_1_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[0];
            float _Split_4ca30533313a443cbed9e663a9078bd3_G_2_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[1];
            float _Split_4ca30533313a443cbed9e663a9078bd3_B_3_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[2];
            float _Split_4ca30533313a443cbed9e663a9078bd3_A_4_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[3];
            float _Subtract_8e8c206a123b440d92a6613c55629432_Out_2_Float;
            Unity_Subtract_float(_Split_4ca30533313a443cbed9e663a9078bd3_A_4_Float, float(1), _Subtract_8e8c206a123b440d92a6613c55629432_Out_2_Float);
            float _Subtract_c1a93ffe2989497698a04bc7b908da66_Out_2_Float;
            Unity_Subtract_float(_SceneDepth_6c648c418b2c4df48061e3694c0deade_Out_1_Float, _Subtract_8e8c206a123b440d92a6613c55629432_Out_2_Float, _Subtract_c1a93ffe2989497698a04bc7b908da66_Out_2_Float);
            float _Property_b27fb059166a4fcc8ee3c8de86f584a8_Out_0_Float = _Fade_Depth;
            float _Divide_5c7af79d3663411d88012bd4d64c9f68_Out_2_Float;
            Unity_Divide_float(_Subtract_c1a93ffe2989497698a04bc7b908da66_Out_2_Float, _Property_b27fb059166a4fcc8ee3c8de86f584a8_Out_0_Float, _Divide_5c7af79d3663411d88012bd4d64c9f68_Out_2_Float);
            float _Saturate_4b391c51d8da40f3a6fb4b14f1cba9fd_Out_1_Float;
            Unity_Saturate_float(_Divide_5c7af79d3663411d88012bd4d64c9f68_Out_2_Float, _Saturate_4b391c51d8da40f3a6fb4b14f1cba9fd_Out_1_Float);
            surface.Alpha = _Saturate_4b391c51d8da40f3a6fb4b14f1cba9fd_Out_1_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        #define REQUIRE_DEPTH_TEXTURE
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS : INTERP0;
             float3 normalWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Rotate_Projection;
        float _Property;
        float _Noise_Speed;
        float4 _Noise_Remap;
        float _Noise_Height;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Curvature_Radius;
        float _Fresnel_Power;
        float _Fresnel_Opacity;
        float _Fade_Depth;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);
            float s, c;
            sincos(Rotation, s, c);
            Axis = normalize(Axis);
            Out = In * c + cross(Axis, In) * s + Axis * dot(Axis, In) * (1 - c);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), ViewDir))), Power);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_c31794c1f855479282ee5da197fed9fd_Out_0_Float = _Noise_Edge_1;
            float _Property_077e847eba5748bb86160070c2deaa64_Out_0_Float = _Noise_Edge_2;
            float4 _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4 = _Rotate_Projection;
            float _Split_b708f28d3c90475d89d47e9a31f41a52_R_1_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[0];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_G_2_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[1];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_B_3_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[2];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_A_4_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[3];
            float3 _RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4.xyz), _Split_b708f28d3c90475d89d47e9a31f41a52_A_4_Float, _RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3);
            float _Property_d539908abf584c3aa4b8fd8280bdbd31_Out_0_Float = _Noise_Speed;
            float _Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_d539908abf584c3aa4b8fd8280bdbd31_Out_0_Float, _Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float);
            float2 _TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float.xx), _TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2);
            float _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float = _Property;
            float _GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2, _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float, _GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float);
            float2 _TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2);
            float _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2, _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float, _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float);
            float _Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float;
            Unity_Add_float(_GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float, _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float, _Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float);
            float _Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float;
            Unity_Divide_float(_Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float, float(2), _Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float);
            float _Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float;
            Unity_Saturate_float(_Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float, _Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float);
            float _Property_eda1028b8e1145128ef9af3133ed5946_Out_0_Float = _Noise_Power;
            float _Power_595cf53127f5490ab915867f6162c276_Out_2_Float;
            Unity_Power_float(_Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float, _Property_eda1028b8e1145128ef9af3133ed5946_Out_0_Float, _Power_595cf53127f5490ab915867f6162c276_Out_2_Float);
            float4 _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4 = _Noise_Remap;
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_R_1_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[0];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_G_2_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[1];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_B_3_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[2];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_A_4_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[3];
            float4 _Combine_3e35a3c53b5242308717f2a942447d7e_RGBA_4_Vector4;
            float3 _Combine_3e35a3c53b5242308717f2a942447d7e_RGB_5_Vector3;
            float2 _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2;
            Unity_Combine_float(_Split_a2df4ccdf77b4b7ea4d10025134553ab_R_1_Float, _Split_a2df4ccdf77b4b7ea4d10025134553ab_G_2_Float, float(0), float(0), _Combine_3e35a3c53b5242308717f2a942447d7e_RGBA_4_Vector4, _Combine_3e35a3c53b5242308717f2a942447d7e_RGB_5_Vector3, _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2);
            float4 _Combine_6707e1830a8b42368404e0ba8aec185c_RGBA_4_Vector4;
            float3 _Combine_6707e1830a8b42368404e0ba8aec185c_RGB_5_Vector3;
            float2 _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2;
            Unity_Combine_float(_Split_a2df4ccdf77b4b7ea4d10025134553ab_B_3_Float, _Split_a2df4ccdf77b4b7ea4d10025134553ab_A_4_Float, float(0), float(0), _Combine_6707e1830a8b42368404e0ba8aec185c_RGBA_4_Vector4, _Combine_6707e1830a8b42368404e0ba8aec185c_RGB_5_Vector3, _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2);
            float _Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float;
            Unity_Remap_float(_Power_595cf53127f5490ab915867f6162c276_Out_2_Float, _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2, _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2, _Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float);
            float _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float;
            Unity_Absolute_float(_Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float, _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float);
            float _Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float;
            Unity_Smoothstep_float(_Property_c31794c1f855479282ee5da197fed9fd_Out_0_Float, _Property_077e847eba5748bb86160070c2deaa64_Out_0_Float, _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float, _Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float);
            float _Property_84ce8b8799384e41913c4d725ccacf18_Out_0_Float = _Base_Speed;
            float _Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_84ce8b8799384e41913c4d725ccacf18_Out_0_Float, _Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float);
            float2 _TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float.xx), _TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2);
            float _Property_1b6de3fe3f0246789b9234d0871589f3_Out_0_Float = _Base_Scale;
            float _GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2, _Property_1b6de3fe3f0246789b9234d0871589f3_Out_0_Float, _GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float);
            float _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float = _Base_Strength;
            float _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float;
            Unity_Multiply_float_float(_GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float, _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float, _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float);
            float _Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float;
            Unity_Add_float(_Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float, _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float, _Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float);
            float _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float;
            Unity_Add_float(float(0), _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float, _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float);
            float _Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float;
            Unity_Divide_float(_Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float, _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float, _Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float);
            float3 _Multiply_add6f8a43114485889343105909217f2_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float.xxx), _Multiply_add6f8a43114485889343105909217f2_Out_2_Vector3);
            float _Property_642c7b99ea2a446a864f6e04b00f09c7_Out_0_Float = _Noise_Height;
            float3 _Multiply_6455f710f60b4a07bbd03b8e981621c1_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_add6f8a43114485889343105909217f2_Out_2_Vector3, (_Property_642c7b99ea2a446a864f6e04b00f09c7_Out_0_Float.xxx), _Multiply_6455f710f60b4a07bbd03b8e981621c1_Out_2_Vector3);
            float3 _Add_86d221c98c2b46c599df05fc07583635_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_6455f710f60b4a07bbd03b8e981621c1_Out_2_Vector3, _Add_86d221c98c2b46c599df05fc07583635_Out_2_Vector3);
            description.Position = _Add_86d221c98c2b46c599df05fc07583635_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_e0d03b59487c437fa1bb9173ce8e8def_Out_0_Vector4 = _Color_Peak;
            float4 _Property_0391558ec0484a35be8ad529889a9447_Out_0_Vector4 = _Color_Valley;
            float _Property_c31794c1f855479282ee5da197fed9fd_Out_0_Float = _Noise_Edge_1;
            float _Property_077e847eba5748bb86160070c2deaa64_Out_0_Float = _Noise_Edge_2;
            float4 _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4 = _Rotate_Projection;
            float _Split_b708f28d3c90475d89d47e9a31f41a52_R_1_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[0];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_G_2_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[1];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_B_3_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[2];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_A_4_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[3];
            float3 _RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4.xyz), _Split_b708f28d3c90475d89d47e9a31f41a52_A_4_Float, _RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3);
            float _Property_d539908abf584c3aa4b8fd8280bdbd31_Out_0_Float = _Noise_Speed;
            float _Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_d539908abf584c3aa4b8fd8280bdbd31_Out_0_Float, _Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float);
            float2 _TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float.xx), _TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2);
            float _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float = _Property;
            float _GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2, _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float, _GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float);
            float2 _TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2);
            float _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2, _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float, _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float);
            float _Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float;
            Unity_Add_float(_GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float, _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float, _Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float);
            float _Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float;
            Unity_Divide_float(_Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float, float(2), _Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float);
            float _Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float;
            Unity_Saturate_float(_Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float, _Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float);
            float _Property_eda1028b8e1145128ef9af3133ed5946_Out_0_Float = _Noise_Power;
            float _Power_595cf53127f5490ab915867f6162c276_Out_2_Float;
            Unity_Power_float(_Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float, _Property_eda1028b8e1145128ef9af3133ed5946_Out_0_Float, _Power_595cf53127f5490ab915867f6162c276_Out_2_Float);
            float4 _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4 = _Noise_Remap;
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_R_1_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[0];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_G_2_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[1];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_B_3_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[2];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_A_4_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[3];
            float4 _Combine_3e35a3c53b5242308717f2a942447d7e_RGBA_4_Vector4;
            float3 _Combine_3e35a3c53b5242308717f2a942447d7e_RGB_5_Vector3;
            float2 _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2;
            Unity_Combine_float(_Split_a2df4ccdf77b4b7ea4d10025134553ab_R_1_Float, _Split_a2df4ccdf77b4b7ea4d10025134553ab_G_2_Float, float(0), float(0), _Combine_3e35a3c53b5242308717f2a942447d7e_RGBA_4_Vector4, _Combine_3e35a3c53b5242308717f2a942447d7e_RGB_5_Vector3, _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2);
            float4 _Combine_6707e1830a8b42368404e0ba8aec185c_RGBA_4_Vector4;
            float3 _Combine_6707e1830a8b42368404e0ba8aec185c_RGB_5_Vector3;
            float2 _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2;
            Unity_Combine_float(_Split_a2df4ccdf77b4b7ea4d10025134553ab_B_3_Float, _Split_a2df4ccdf77b4b7ea4d10025134553ab_A_4_Float, float(0), float(0), _Combine_6707e1830a8b42368404e0ba8aec185c_RGBA_4_Vector4, _Combine_6707e1830a8b42368404e0ba8aec185c_RGB_5_Vector3, _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2);
            float _Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float;
            Unity_Remap_float(_Power_595cf53127f5490ab915867f6162c276_Out_2_Float, _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2, _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2, _Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float);
            float _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float;
            Unity_Absolute_float(_Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float, _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float);
            float _Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float;
            Unity_Smoothstep_float(_Property_c31794c1f855479282ee5da197fed9fd_Out_0_Float, _Property_077e847eba5748bb86160070c2deaa64_Out_0_Float, _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float, _Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float);
            float _Property_84ce8b8799384e41913c4d725ccacf18_Out_0_Float = _Base_Speed;
            float _Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_84ce8b8799384e41913c4d725ccacf18_Out_0_Float, _Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float);
            float2 _TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float.xx), _TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2);
            float _Property_1b6de3fe3f0246789b9234d0871589f3_Out_0_Float = _Base_Scale;
            float _GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2, _Property_1b6de3fe3f0246789b9234d0871589f3_Out_0_Float, _GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float);
            float _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float = _Base_Strength;
            float _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float;
            Unity_Multiply_float_float(_GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float, _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float, _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float);
            float _Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float;
            Unity_Add_float(_Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float, _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float, _Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float);
            float _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float;
            Unity_Add_float(float(0), _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float, _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float);
            float _Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float;
            Unity_Divide_float(_Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float, _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float, _Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float);
            float4 _Lerp_8b39e0711ea040d78445a25812694429_Out_3_Vector4;
            Unity_Lerp_float4(_Property_e0d03b59487c437fa1bb9173ce8e8def_Out_0_Vector4, _Property_0391558ec0484a35be8ad529889a9447_Out_0_Vector4, (_Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float.xxxx), _Lerp_8b39e0711ea040d78445a25812694429_Out_3_Vector4);
            float _Property_00ab0eb814ff416fb477c1ba87ca4d7d_Out_0_Float = _Fresnel_Power;
            float _FresnelEffect_32b3fe63957e43159419f1cfe6bd2fcb_Out_3_Float;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_00ab0eb814ff416fb477c1ba87ca4d7d_Out_0_Float, _FresnelEffect_32b3fe63957e43159419f1cfe6bd2fcb_Out_3_Float);
            float _Multiply_176e613ba30f4d208ddf59298dac4eb0_Out_2_Float;
            Unity_Multiply_float_float(_Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float, _FresnelEffect_32b3fe63957e43159419f1cfe6bd2fcb_Out_3_Float, _Multiply_176e613ba30f4d208ddf59298dac4eb0_Out_2_Float);
            float _Property_f55d0bc6027d404ab1c864ca2a58ff0a_Out_0_Float = _Fresnel_Opacity;
            float _Multiply_741f1176301c4398a41f676c14f3b6a2_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_176e613ba30f4d208ddf59298dac4eb0_Out_2_Float, _Property_f55d0bc6027d404ab1c864ca2a58ff0a_Out_0_Float, _Multiply_741f1176301c4398a41f676c14f3b6a2_Out_2_Float);
            float4 _Add_5a18e1f81a404145a87336aac341f2ef_Out_2_Vector4;
            Unity_Add_float4(_Lerp_8b39e0711ea040d78445a25812694429_Out_3_Vector4, (_Multiply_741f1176301c4398a41f676c14f3b6a2_Out_2_Float.xxxx), _Add_5a18e1f81a404145a87336aac341f2ef_Out_2_Vector4);
            float _SceneDepth_6c648c418b2c4df48061e3694c0deade_Out_1_Float;
            Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_6c648c418b2c4df48061e3694c0deade_Out_1_Float);
            float4 _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_4ca30533313a443cbed9e663a9078bd3_R_1_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[0];
            float _Split_4ca30533313a443cbed9e663a9078bd3_G_2_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[1];
            float _Split_4ca30533313a443cbed9e663a9078bd3_B_3_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[2];
            float _Split_4ca30533313a443cbed9e663a9078bd3_A_4_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[3];
            float _Subtract_8e8c206a123b440d92a6613c55629432_Out_2_Float;
            Unity_Subtract_float(_Split_4ca30533313a443cbed9e663a9078bd3_A_4_Float, float(1), _Subtract_8e8c206a123b440d92a6613c55629432_Out_2_Float);
            float _Subtract_c1a93ffe2989497698a04bc7b908da66_Out_2_Float;
            Unity_Subtract_float(_SceneDepth_6c648c418b2c4df48061e3694c0deade_Out_1_Float, _Subtract_8e8c206a123b440d92a6613c55629432_Out_2_Float, _Subtract_c1a93ffe2989497698a04bc7b908da66_Out_2_Float);
            float _Property_b27fb059166a4fcc8ee3c8de86f584a8_Out_0_Float = _Fade_Depth;
            float _Divide_5c7af79d3663411d88012bd4d64c9f68_Out_2_Float;
            Unity_Divide_float(_Subtract_c1a93ffe2989497698a04bc7b908da66_Out_2_Float, _Property_b27fb059166a4fcc8ee3c8de86f584a8_Out_0_Float, _Divide_5c7af79d3663411d88012bd4d64c9f68_Out_2_Float);
            float _Saturate_4b391c51d8da40f3a6fb4b14f1cba9fd_Out_1_Float;
            Unity_Saturate_float(_Divide_5c7af79d3663411d88012bd4d64c9f68_Out_2_Float, _Saturate_4b391c51d8da40f3a6fb4b14f1cba9fd_Out_1_Float);
            surface.BaseColor = (_Add_5a18e1f81a404145a87336aac341f2ef_Out_2_Vector4.xyz);
            surface.Alpha = _Saturate_4b391c51d8da40f3a6fb4b14f1cba9fd_Out_1_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Universal 2D"
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        #define _ALPHATEST_ON 1
        #define REQUIRE_DEPTH_TEXTURE
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS : INTERP0;
             float3 normalWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Rotate_Projection;
        float _Property;
        float _Noise_Speed;
        float4 _Noise_Remap;
        float _Noise_Height;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Curvature_Radius;
        float _Fresnel_Power;
        float _Fresnel_Opacity;
        float _Fade_Depth;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);
            float s, c;
            sincos(Rotation, s, c);
            Axis = normalize(Axis);
            Out = In * c + cross(Axis, In) * s + Axis * dot(Axis, In) * (1 - c);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), ViewDir))), Power);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_c31794c1f855479282ee5da197fed9fd_Out_0_Float = _Noise_Edge_1;
            float _Property_077e847eba5748bb86160070c2deaa64_Out_0_Float = _Noise_Edge_2;
            float4 _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4 = _Rotate_Projection;
            float _Split_b708f28d3c90475d89d47e9a31f41a52_R_1_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[0];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_G_2_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[1];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_B_3_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[2];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_A_4_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[3];
            float3 _RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4.xyz), _Split_b708f28d3c90475d89d47e9a31f41a52_A_4_Float, _RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3);
            float _Property_d539908abf584c3aa4b8fd8280bdbd31_Out_0_Float = _Noise_Speed;
            float _Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_d539908abf584c3aa4b8fd8280bdbd31_Out_0_Float, _Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float);
            float2 _TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float.xx), _TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2);
            float _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float = _Property;
            float _GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2, _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float, _GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float);
            float2 _TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2);
            float _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2, _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float, _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float);
            float _Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float;
            Unity_Add_float(_GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float, _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float, _Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float);
            float _Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float;
            Unity_Divide_float(_Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float, float(2), _Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float);
            float _Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float;
            Unity_Saturate_float(_Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float, _Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float);
            float _Property_eda1028b8e1145128ef9af3133ed5946_Out_0_Float = _Noise_Power;
            float _Power_595cf53127f5490ab915867f6162c276_Out_2_Float;
            Unity_Power_float(_Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float, _Property_eda1028b8e1145128ef9af3133ed5946_Out_0_Float, _Power_595cf53127f5490ab915867f6162c276_Out_2_Float);
            float4 _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4 = _Noise_Remap;
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_R_1_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[0];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_G_2_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[1];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_B_3_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[2];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_A_4_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[3];
            float4 _Combine_3e35a3c53b5242308717f2a942447d7e_RGBA_4_Vector4;
            float3 _Combine_3e35a3c53b5242308717f2a942447d7e_RGB_5_Vector3;
            float2 _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2;
            Unity_Combine_float(_Split_a2df4ccdf77b4b7ea4d10025134553ab_R_1_Float, _Split_a2df4ccdf77b4b7ea4d10025134553ab_G_2_Float, float(0), float(0), _Combine_3e35a3c53b5242308717f2a942447d7e_RGBA_4_Vector4, _Combine_3e35a3c53b5242308717f2a942447d7e_RGB_5_Vector3, _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2);
            float4 _Combine_6707e1830a8b42368404e0ba8aec185c_RGBA_4_Vector4;
            float3 _Combine_6707e1830a8b42368404e0ba8aec185c_RGB_5_Vector3;
            float2 _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2;
            Unity_Combine_float(_Split_a2df4ccdf77b4b7ea4d10025134553ab_B_3_Float, _Split_a2df4ccdf77b4b7ea4d10025134553ab_A_4_Float, float(0), float(0), _Combine_6707e1830a8b42368404e0ba8aec185c_RGBA_4_Vector4, _Combine_6707e1830a8b42368404e0ba8aec185c_RGB_5_Vector3, _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2);
            float _Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float;
            Unity_Remap_float(_Power_595cf53127f5490ab915867f6162c276_Out_2_Float, _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2, _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2, _Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float);
            float _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float;
            Unity_Absolute_float(_Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float, _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float);
            float _Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float;
            Unity_Smoothstep_float(_Property_c31794c1f855479282ee5da197fed9fd_Out_0_Float, _Property_077e847eba5748bb86160070c2deaa64_Out_0_Float, _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float, _Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float);
            float _Property_84ce8b8799384e41913c4d725ccacf18_Out_0_Float = _Base_Speed;
            float _Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_84ce8b8799384e41913c4d725ccacf18_Out_0_Float, _Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float);
            float2 _TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float.xx), _TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2);
            float _Property_1b6de3fe3f0246789b9234d0871589f3_Out_0_Float = _Base_Scale;
            float _GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2, _Property_1b6de3fe3f0246789b9234d0871589f3_Out_0_Float, _GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float);
            float _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float = _Base_Strength;
            float _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float;
            Unity_Multiply_float_float(_GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float, _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float, _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float);
            float _Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float;
            Unity_Add_float(_Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float, _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float, _Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float);
            float _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float;
            Unity_Add_float(float(0), _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float, _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float);
            float _Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float;
            Unity_Divide_float(_Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float, _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float, _Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float);
            float3 _Multiply_add6f8a43114485889343105909217f2_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float.xxx), _Multiply_add6f8a43114485889343105909217f2_Out_2_Vector3);
            float _Property_642c7b99ea2a446a864f6e04b00f09c7_Out_0_Float = _Noise_Height;
            float3 _Multiply_6455f710f60b4a07bbd03b8e981621c1_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_add6f8a43114485889343105909217f2_Out_2_Vector3, (_Property_642c7b99ea2a446a864f6e04b00f09c7_Out_0_Float.xxx), _Multiply_6455f710f60b4a07bbd03b8e981621c1_Out_2_Vector3);
            float3 _Add_86d221c98c2b46c599df05fc07583635_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_6455f710f60b4a07bbd03b8e981621c1_Out_2_Vector3, _Add_86d221c98c2b46c599df05fc07583635_Out_2_Vector3);
            description.Position = _Add_86d221c98c2b46c599df05fc07583635_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_e0d03b59487c437fa1bb9173ce8e8def_Out_0_Vector4 = _Color_Peak;
            float4 _Property_0391558ec0484a35be8ad529889a9447_Out_0_Vector4 = _Color_Valley;
            float _Property_c31794c1f855479282ee5da197fed9fd_Out_0_Float = _Noise_Edge_1;
            float _Property_077e847eba5748bb86160070c2deaa64_Out_0_Float = _Noise_Edge_2;
            float4 _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4 = _Rotate_Projection;
            float _Split_b708f28d3c90475d89d47e9a31f41a52_R_1_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[0];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_G_2_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[1];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_B_3_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[2];
            float _Split_b708f28d3c90475d89d47e9a31f41a52_A_4_Float = _Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4[3];
            float3 _RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_0a5922efdf724b66a3fc4207a7f6c43e_Out_0_Vector4.xyz), _Split_b708f28d3c90475d89d47e9a31f41a52_A_4_Float, _RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3);
            float _Property_d539908abf584c3aa4b8fd8280bdbd31_Out_0_Float = _Noise_Speed;
            float _Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_d539908abf584c3aa4b8fd8280bdbd31_Out_0_Float, _Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float);
            float2 _TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_98e31e7e96444d10b4cf05cd911db416_Out_2_Float.xx), _TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2);
            float _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float = _Property;
            float _GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_712c21f2fbcb41c4aef58c576e3c2162_Out_3_Vector2, _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float, _GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float);
            float2 _TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2);
            float _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_265622a4046f4ee892e36d78b91ef27a_Out_3_Vector2, _Property_b76ff4f09dcb4404b6828e48193702ff_Out_0_Float, _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float);
            float _Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float;
            Unity_Add_float(_GradientNoise_aa88ecb7947947519ce903d3d37f7475_Out_2_Float, _GradientNoise_e6f5819cb6b34cefa4039f323235458d_Out_2_Float, _Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float);
            float _Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float;
            Unity_Divide_float(_Add_b67082bf66ba4167ad61cd2c764ec666_Out_2_Float, float(2), _Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float);
            float _Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float;
            Unity_Saturate_float(_Divide_068c72aa343d451b90cbaa18be3e1131_Out_2_Float, _Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float);
            float _Property_eda1028b8e1145128ef9af3133ed5946_Out_0_Float = _Noise_Power;
            float _Power_595cf53127f5490ab915867f6162c276_Out_2_Float;
            Unity_Power_float(_Saturate_04a83879f12348eb9dfbbbeb2bdc030a_Out_1_Float, _Property_eda1028b8e1145128ef9af3133ed5946_Out_0_Float, _Power_595cf53127f5490ab915867f6162c276_Out_2_Float);
            float4 _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4 = _Noise_Remap;
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_R_1_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[0];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_G_2_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[1];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_B_3_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[2];
            float _Split_a2df4ccdf77b4b7ea4d10025134553ab_A_4_Float = _Property_d08e7530ee9149e2b486ae560aaefbba_Out_0_Vector4[3];
            float4 _Combine_3e35a3c53b5242308717f2a942447d7e_RGBA_4_Vector4;
            float3 _Combine_3e35a3c53b5242308717f2a942447d7e_RGB_5_Vector3;
            float2 _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2;
            Unity_Combine_float(_Split_a2df4ccdf77b4b7ea4d10025134553ab_R_1_Float, _Split_a2df4ccdf77b4b7ea4d10025134553ab_G_2_Float, float(0), float(0), _Combine_3e35a3c53b5242308717f2a942447d7e_RGBA_4_Vector4, _Combine_3e35a3c53b5242308717f2a942447d7e_RGB_5_Vector3, _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2);
            float4 _Combine_6707e1830a8b42368404e0ba8aec185c_RGBA_4_Vector4;
            float3 _Combine_6707e1830a8b42368404e0ba8aec185c_RGB_5_Vector3;
            float2 _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2;
            Unity_Combine_float(_Split_a2df4ccdf77b4b7ea4d10025134553ab_B_3_Float, _Split_a2df4ccdf77b4b7ea4d10025134553ab_A_4_Float, float(0), float(0), _Combine_6707e1830a8b42368404e0ba8aec185c_RGBA_4_Vector4, _Combine_6707e1830a8b42368404e0ba8aec185c_RGB_5_Vector3, _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2);
            float _Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float;
            Unity_Remap_float(_Power_595cf53127f5490ab915867f6162c276_Out_2_Float, _Combine_3e35a3c53b5242308717f2a942447d7e_RG_6_Vector2, _Combine_6707e1830a8b42368404e0ba8aec185c_RG_6_Vector2, _Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float);
            float _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float;
            Unity_Absolute_float(_Remap_c3eb9233328344c88e971c6cee4c9a45_Out_3_Float, _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float);
            float _Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float;
            Unity_Smoothstep_float(_Property_c31794c1f855479282ee5da197fed9fd_Out_0_Float, _Property_077e847eba5748bb86160070c2deaa64_Out_0_Float, _Absolute_1ddbf0e6945e4cf082d56c0c47b08eb9_Out_1_Float, _Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float);
            float _Property_84ce8b8799384e41913c4d725ccacf18_Out_0_Float = _Base_Speed;
            float _Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_84ce8b8799384e41913c4d725ccacf18_Out_0_Float, _Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float);
            float2 _TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_84c40f792220462aa2fb35f3ee6fbb5a_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_5ab1e8c5c32b4574a2eee68b7298e92a_Out_2_Float.xx), _TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2);
            float _Property_1b6de3fe3f0246789b9234d0871589f3_Out_0_Float = _Base_Scale;
            float _GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_83a17d1a4198455291df339053031fe2_Out_3_Vector2, _Property_1b6de3fe3f0246789b9234d0871589f3_Out_0_Float, _GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float);
            float _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float = _Base_Strength;
            float _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float;
            Unity_Multiply_float_float(_GradientNoise_548c7866d253443c8b085941a47e1088_Out_2_Float, _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float, _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float);
            float _Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float;
            Unity_Add_float(_Smoothstep_bf72213040b349d2b9b2fb74170f59f0_Out_3_Float, _Multiply_3b60192c99014404853289efe27ed949_Out_2_Float, _Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float);
            float _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float;
            Unity_Add_float(float(0), _Property_1bcdf4732db24f38b6ee04442769a378_Out_0_Float, _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float);
            float _Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float;
            Unity_Divide_float(_Add_bd5d69e938e74db7bba9556d8f07eea4_Out_2_Float, _Add_a7c2c007fb1c417590c26f6c16e25af8_Out_2_Float, _Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float);
            float4 _Lerp_8b39e0711ea040d78445a25812694429_Out_3_Vector4;
            Unity_Lerp_float4(_Property_e0d03b59487c437fa1bb9173ce8e8def_Out_0_Vector4, _Property_0391558ec0484a35be8ad529889a9447_Out_0_Vector4, (_Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float.xxxx), _Lerp_8b39e0711ea040d78445a25812694429_Out_3_Vector4);
            float _Property_00ab0eb814ff416fb477c1ba87ca4d7d_Out_0_Float = _Fresnel_Power;
            float _FresnelEffect_32b3fe63957e43159419f1cfe6bd2fcb_Out_3_Float;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_00ab0eb814ff416fb477c1ba87ca4d7d_Out_0_Float, _FresnelEffect_32b3fe63957e43159419f1cfe6bd2fcb_Out_3_Float);
            float _Multiply_176e613ba30f4d208ddf59298dac4eb0_Out_2_Float;
            Unity_Multiply_float_float(_Divide_cbc3df8699f74999b0f658ecd0ab7ee5_Out_2_Float, _FresnelEffect_32b3fe63957e43159419f1cfe6bd2fcb_Out_3_Float, _Multiply_176e613ba30f4d208ddf59298dac4eb0_Out_2_Float);
            float _Property_f55d0bc6027d404ab1c864ca2a58ff0a_Out_0_Float = _Fresnel_Opacity;
            float _Multiply_741f1176301c4398a41f676c14f3b6a2_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_176e613ba30f4d208ddf59298dac4eb0_Out_2_Float, _Property_f55d0bc6027d404ab1c864ca2a58ff0a_Out_0_Float, _Multiply_741f1176301c4398a41f676c14f3b6a2_Out_2_Float);
            float4 _Add_5a18e1f81a404145a87336aac341f2ef_Out_2_Vector4;
            Unity_Add_float4(_Lerp_8b39e0711ea040d78445a25812694429_Out_3_Vector4, (_Multiply_741f1176301c4398a41f676c14f3b6a2_Out_2_Float.xxxx), _Add_5a18e1f81a404145a87336aac341f2ef_Out_2_Vector4);
            float _SceneDepth_6c648c418b2c4df48061e3694c0deade_Out_1_Float;
            Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_6c648c418b2c4df48061e3694c0deade_Out_1_Float);
            float4 _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_4ca30533313a443cbed9e663a9078bd3_R_1_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[0];
            float _Split_4ca30533313a443cbed9e663a9078bd3_G_2_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[1];
            float _Split_4ca30533313a443cbed9e663a9078bd3_B_3_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[2];
            float _Split_4ca30533313a443cbed9e663a9078bd3_A_4_Float = _ScreenPosition_20c8d90d1f9a4aac9e70af98da69d210_Out_0_Vector4[3];
            float _Subtract_8e8c206a123b440d92a6613c55629432_Out_2_Float;
            Unity_Subtract_float(_Split_4ca30533313a443cbed9e663a9078bd3_A_4_Float, float(1), _Subtract_8e8c206a123b440d92a6613c55629432_Out_2_Float);
            float _Subtract_c1a93ffe2989497698a04bc7b908da66_Out_2_Float;
            Unity_Subtract_float(_SceneDepth_6c648c418b2c4df48061e3694c0deade_Out_1_Float, _Subtract_8e8c206a123b440d92a6613c55629432_Out_2_Float, _Subtract_c1a93ffe2989497698a04bc7b908da66_Out_2_Float);
            float _Property_b27fb059166a4fcc8ee3c8de86f584a8_Out_0_Float = _Fade_Depth;
            float _Divide_5c7af79d3663411d88012bd4d64c9f68_Out_2_Float;
            Unity_Divide_float(_Subtract_c1a93ffe2989497698a04bc7b908da66_Out_2_Float, _Property_b27fb059166a4fcc8ee3c8de86f584a8_Out_0_Float, _Divide_5c7af79d3663411d88012bd4d64c9f68_Out_2_Float);
            float _Saturate_4b391c51d8da40f3a6fb4b14f1cba9fd_Out_1_Float;
            Unity_Saturate_float(_Divide_5c7af79d3663411d88012bd4d64c9f68_Out_2_Float, _Saturate_4b391c51d8da40f3a6fb4b14f1cba9fd_Out_1_Float);
            surface.BaseColor = (_Add_5a18e1f81a404145a87336aac341f2ef_Out_2_Vector4.xyz);
            surface.Alpha = _Saturate_4b391c51d8da40f3a6fb4b14f1cba9fd_Out_1_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    FallBack "Hidden/Shader Graph/FallbackError"
}