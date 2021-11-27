Shader "Custom/GooPitShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        _BumpMap ("Bumpmap", 2D) = "bump" {}
        _Amount ("_Amount", Range(0.1,500)) = 3.0
        _ScrollSpeed("X speed", Range(0.0, 50)) = 0

        _WaveA ("Wave A (dir, steepness, wavelength)", Vector) = (1, 0, 0.5, 20)
		_WaveB ("Wave B (dir, steepness, wavelength)", Vector) = (0, 1, 0.25, 10)
        _WaveC ("Wave A (dir, steepness, wavelength)", Vector) = (-1, 0.2, 0.5, 5)

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // surf: surface shader, ver: vertex shader
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        // use this small file to simply graba tiem variable to help with the scrolling
        #include "Flow.cginc"

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _Amount;
        sampler2D _BumpMap;
        fixed _ScrollSpeed;

        float4 _WaveA, _WaveB, _WaveC;

        // https://docs.unity3d.com/520/Documentation/Manual/SL-VertexFragmentShaderExamples.html
        // move verts info ^^

        // im ngl, i have no idea what these lines do, but they need to be here so we let them vibe
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
        // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)


        /*
            GerstnerWave function for generating Gerstner Waves over verts.
        Using more Trochoidal waves rather than sine, allows for control over the sharpness of the 
        crests of the waves and the flatness of the troughs. These values are controlled by the wave
        paramteter.  
        https://en.wikipedia.org/wiki/Trochoidal_wave
        This Gerstner wave function has been adapted from:
            https://catlikecoding.com/unity/tutorials/flow/waves/
        */

		float3 GerstnerWave (
			float4 wave, float3 p, inout float3 tangent, inout float3 binormal
		) {
            // phase speed of the wave, the wave number where wavelength is the lambda
            float steepness = wave.z;
		    float wavelength = wave.w;

		    float k = 2 * UNITY_PI / wavelength;
            float2 d = normalize(wave.xy);
            float c = sqrt(9.8 / k);
			float f = k * (dot(d, p.xz) - c * _Time.y);

			tangent += float3(
				-d.x * d.x * (steepness * sin(f)),
				d.x * (steepness * cos(f)),
				-d.x * d.y * (steepness * sin(f))
			);
			binormal += float3(
				-d.x * d.y * (steepness * sin(f)),
				d.y * (steepness * cos(f)),
				-d.y * d.y * (steepness * sin(f))
			);
			return float3(
				d.x * ((steepness / k) * cos(f)),
				(steepness / k) * sin(f),
				d.y * ((steepness / k) * cos(f))
			);
		}

        void vert(inout appdata_full vertexData) 
        {
            // sourced adapted from: https://catlikecoding.com/unity/tutorials/flow/waves/
            float3 initVertGridPoint = vertexData.vertex.xyz;
			float3 tangent = 0;
			float3 binormal = 0;
			float3 cumulativePos = initVertGridPoint;
            // have multiple waves operating over the same mesh
			cumulativePos += GerstnerWave(_WaveA, initVertGridPoint, tangent, binormal);
			cumulativePos += GerstnerWave(_WaveB, initVertGridPoint, tangent, binormal);
            // cumulativePos += GerstnerWave(_WaveC, initVertGridPoint, tangent, binormal);
			float3 normal = normalize(cross(binormal, tangent));
			vertexData.vertex.xyz = cumulativePos;
			vertexData.normal = normal;
        }

        // can apply bumpMap in surface shader
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            // o.Albedo = c.rgb; // the default, just apply albedo
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;

            // BumpMap (NormalMap) calculations
            // Scroll normal map & Albedo based on time (from the included "Flow.cginc") + scalar
            float2 uvScrollNormal = FlowUV(IN.uv_BumpMap, _Time.y / _ScrollSpeed);
            float2 uvScrollAlbedo = FlowUV(IN.uv_MainTex, _Time.y / _ScrollSpeed);
            float3 normalMap = UnpackNormal(tex2D(_BumpMap, uvScrollNormal));
            // apply intensity scaling
            normalMap.x *= _Amount;
            normalMap.y *= _Amount;

            o.Normal = normalize(normalMap.rgb);
            o.Albedo = tex2D (_MainTex, uvScrollAlbedo) * _Color;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
