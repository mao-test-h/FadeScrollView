// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

// uGUIのScrollViewに於ける要素の透過処理を行うためのシェーダー
// # Usage
// - "_Center"にはScrollRectの中心座標を入れること
// - "_FadeIntensity"は任意で設定
// - 後はScrollRectの要素にこれを適用したMaterialを設定
Shader "Custom/UI/FadeColumn"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)

        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0


        // フェードの境界(top, bottom, left, right)
        [HideInInspector] _Border ("_Border", Vector) = (0.0, 0.0, 0.0, 0.0)
        // フェードの影響度
        _FadeIntensity ("Fade Intensity", Float) = 0.01
        // 縦ラインのフェードの有効化
        [Toggle(FADE_VERTICAL)] _OnFadeVertical ("On Fade Vertical", Float) = 0
        // 横ラインのフェードの有効化
        [Toggle(FADE_HORIZONTAL)] __OnFadeHorizontal ("On Fade Horizontal", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            Name "Default"
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile __ UNITY_UI_CLIP_RECT
            #pragma multi_compile __ UNITY_UI_ALPHACLIP
            #pragma multi_compile __ FADE_VERTICAL
            #pragma multi_compile __ FADE_HORIZONTAL

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 texcoord  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;

            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.worldPosition = v.vertex;
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

                OUT.texcoord = v.texcoord;

                OUT.color = v.color * _Color;
                return OUT;
            }

            sampler2D _MainTex;
            float4 _Border;
            float _FadeIntensity;

            fixed4 frag(v2f IN) : SV_Target
            {
                half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;

                // 境界の中央の算出
                float2 center = float2(lerp(_Border.z, _Border.w, 0.5), lerp(_Border.x, _Border.y, 0.5));

                // 境界の中央から離れるに連れて薄くしていく
                #if FADE_VERTICAL
                if(IN.worldPosition.y >= center.y || IN.worldPosition.y < center.y)
                {
                    // 縦ライン
                    float scaleY = (_Border.x - _Border.y) / 2.0;
                    float offsetY = IN.worldPosition.y - center.y;
                    color.a -= ((abs(offsetY) / scaleY)) * _FadeIntensity;
                }
                #endif
                #if FADE_HORIZONTAL
                if(IN.worldPosition.x >= center.x || IN.worldPosition.x < center.x)
                {
                    // 横ライン
                    float scaleX = (_Border.z - _Border.w) / 2.0;
                    float offsetX = IN.worldPosition.x - center.x;
                    color.a -= ((abs(offsetX) / scaleX)) * _FadeIntensity;
                }
                #endif

                #ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                clip (color.a - 0.001);
                #endif

                return color;
            }
        ENDCG
        }
    }
}
