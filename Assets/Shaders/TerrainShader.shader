Shader "Custom/TerrainShader"
{
    Properties
    {
        _CliffTex("Cliff texture", 2D) = "white" {}
        [Normal]_CliffNormal("Cliff normal", 2D) = "bump" {} 
        _CliffNormalStrength("Cliff normal strength", float) = 1
        _CliffSmoothness("Cliff smoothness", Range(0,1)) = 0
        _CliffMetallic("Cliff metallic", Range(0,1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
 
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows
 
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
 
        sampler2D _CliffTex;
        sampler2D _CliffNormal;
        float4 _CliffTex_ST;
        float _CliffNormalStrength;
        float _CliffMetallic;
        float _CliffSmoothness;
 
        // Since _Control is where we draw textures to, we can only use max 3 other terrain
        // layers (one for each R,G,B). Alpha use to mask between the other terrain layers.
        // Variables used to interact with the terrain system: 
        // _Control, _Splat0, _Splat1, _Splat2, _Splat3
        sampler2D _Control;
 
        // These are the properties for each other terrain layer in _Control
        // Textures
        sampler2D _Splat0, _Splat1, _Splat2, _Splat3;
        float4 _Splat0_ST, _Splat1_ST, _Splat2_ST, _Splat3_ST;
 
        // Normal Textures
        sampler2D _Normal0, _Normal1, _Normal2, _Normal3;
 
        // Normal scales
        float _NormalScale0, _NormalScale1, _NormalScale2, _NormalScale3;
 
        // Smoothness
        float _Smoothness0, _Smoothness1, _Smoothness2, _Smoothness3;
 
        // Metallic
        float _Metallic0, _Metallic1, _Metallic2, _Metallic3;
 
        // worldNormal and INTERNAL_DATA used to both get the world space normal vector of the mesh, and to
        // apply normal texture.
        struct Input
        {
            float2 uv_Control;
            float3 worldPos;
            float3 worldNormal;
            INTERNAL_DATA
        };
 
 
        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)
 
        // this is where the fun begins..
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // splatControl = sample the _Control texture to get masks for each terain layer
            // R = splat 0, G = splat1, B = splat2, A = splat3
            // use uv_control * splatN coords to avoid having to pass uv's for each splat through the Input sctruct 
            fixed4 splatControl = tex2D(_Control, IN.uv_Control);
            fixed4 col = splatControl.r * tex2D (_Splat0, IN.uv_Control * _Splat0_ST.xy); // mask  splat0 albedo tex w/ r channel of control
            col += splatControl.g * tex2D(_Splat1, IN.uv_Control * _Splat1_ST.xy);  // mask  splat1 albedo tex w/ g channel of control
            col += splatControl.b * tex2D (_Splat2, IN.uv_Control * _Splat2_ST.xy); // mask  splat2 albedo tex w/ b channel of control
            col += splatControl.a * tex2D (_Splat3, IN.uv_Control * _Splat3_ST.xy); // mask  splat3 albedo tex w/ a channel of control
             
            // same process as above but for the normal maps, using UnpackNormalWithScale to do unpack the normal and apply scale (scale can be set in editor)   
            o.Normal = splatControl.r * UnpackNormalWithScale(tex2D(_Normal0, IN.uv_Control * _Splat0_ST.xy), _NormalScale0);
            o.Normal += splatControl.g * UnpackNormalWithScale(tex2D(_Normal1, IN.uv_Control * _Splat1_ST.xy), _NormalScale1);
            o.Normal += splatControl.b * UnpackNormalWithScale(tex2D(_Normal2, IN.uv_Control * _Splat2_ST.xy), _NormalScale2);
            o.Normal += splatControl.a * UnpackNormalWithScale(tex2D(_Normal3, IN.uv_Control * _Splat3_ST.xy), _NormalScale3);
 
            // same as above, except these values are floats not 2D textures
            o.Smoothness = splatControl.r * _Smoothness0;
            o.Smoothness += splatControl.g * _Smoothness1;
            o.Smoothness += splatControl.b * _Smoothness2;
            o.Smoothness += splatControl.a * _Smoothness3;
 
            o.Metallic = splatControl.r * _Metallic0;
            o.Metallic += splatControl.g * _Metallic1;
            o.Metallic += splatControl.b * _Metallic2;
            o.Metallic += splatControl.a * _Metallic3;

            // Finished unpacking everything, now time for biplanar mapping calculations
            // only biplanar (not triplanar) as the terrain layers handel XZ * Y(world normal vector)
            // Threshold is the 'steepness' value for what the shader consoders a cilff (snoothstep used
            // for liear interpolation) - min and max steps adjust the steepness detection values, 
            // for the min max Input values, they are calculated as the dot product (absolute as they have
            // to be positive) of the WorldNormalVector (vec) and a vector that points straight up. This gives
            // the linearly interpolated difference between the current IN normal and our threshold.
            float3 vec = abs(WorldNormalVector (IN, o.Normal));
            float threshold =  smoothstep(0.7, 0.9, abs(dot(vec, float3(0, 1, 0))));
            // calculate color textures
            fixed4 cliffColorXY = tex2D(_CliffTex, IN.worldPos.xy * _CliffTex_ST.xy);
            fixed4 cliffColorYZ = tex2D(_CliffTex, IN.worldPos.yz * _CliffTex_ST.xy);
            fixed4 cliffColor = vec.x * cliffColorYZ + vec.z * cliffColorXY;
            // same process as above, but we again need to unpack the normals and apply the scale value
            float3 cliffNormalXY = UnpackNormalWithScale(tex2D(_CliffNormal, IN.worldPos.xy * _CliffTex_ST.xy), _CliffNormalStrength);
            float3 cliffNormalYZ = UnpackNormalWithScale(tex2D(_CliffNormal, IN.worldPos.yz * _CliffTex_ST.xy), _CliffNormalStrength);
            float3 cliffNormal = vec.x * cliffNormalYZ + vec.z * cliffNormalXY;
 
            // now everything needed has been calculated for each terrain layer(threshold, 
            // cliff color grandients, normals, smoothness and metalic-ness).
            // we combind all these into a single SurfaceOutputStandard o (output) using lerps to 
            // interpolate between each layer's values
            col = lerp(cliffColor, col, threshold);
            o.Normal = lerp(cliffNormal, o.Normal, threshold);
            o.Smoothness = lerp(_CliffSmoothness, o.Smoothness, threshold);
            o.Metallic = lerp(_CliffMetallic, o.Metallic, threshold);
 
            o.Albedo = col.rgb;
            o.Alpha = col.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
