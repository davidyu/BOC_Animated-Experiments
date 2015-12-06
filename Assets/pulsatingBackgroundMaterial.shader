﻿Shader "Custom/pulsatingBackgroundMaterial" {
    Properties {
		_BGColor         ( "Background color", Color ) = ( 0, 0, 0, 1 )
		_BrightLineColor ( "Line color", Color )       = ( .13, 0, .52, 1 )
		_DarkLineColor   ( "Line color 2", Color )     = ( .07, 0, .27, 1 )
		_PlayerPosition  ( "Player position", Vector ) = ( 0, 0, 0, 1 )
		_BallPosition    ( "Ball position", Vector )   = ( 100, 500, 0, 1 )
		_LightIntensity  ( "Spotlight intensity", Vector ) = ( 1.5, 1.5, 1.5, 1 )
		_Darkness		 ( "Darkness", Vector ) = ( 0.8, 0.8, 0.8, 1 )
		_LightFalloff	 ( "Spotlight falloff", Float ) = 250
	}
	SubShader {
		Pass {
			CGPROGRAM

			fixed4 _BGColor;
			fixed4 _BrightLineColor;
			fixed4 _DarkLineColor;
			fixed4 _PlayerPosition;
			fixed4 _BallPosition;
			fixed4 _LightIntensity;
			fixed4 _Darkness;
			fixed _LightFalloff;
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			
			#include "UnityCG.cginc"

			struct VS_OUT {
				float4 pos:SV_POSITION;
				float4 clip;
			};

			VS_OUT vert ( appdata_base v ): POSITION
			{
				VS_OUT o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.clip = ComputeScreenPos( o.pos );
				return o;
			}

			float4 spotlight ( float4 base, float4 pos, float4 lightPos )
			{
				float gradient = 1 - ( clamp( distance( pos.xy, lightPos.xy ), 0, _LightFalloff ) / _LightFalloff );
				float4 lit = base * lerp( _Darkness, _LightIntensity, gradient );
				return lit;
			}
			
			fixed4 frag ( VS_OUT i ) : SV_Target
			{
				fixed4 screen = float4( _ScreenParams.xy * i.clip.xy / i.clip.w, 0, 1 );
				float4 OutColor = ( 0, 0, 0, 1 );

				// render gridlines
				if ( floor( screen.y ) % 40 == 0 || floor( screen.x ) % 40 == 0 )
					OutColor = _BrightLineColor;
				else if ( floor( screen.y ) % 10 == 0 || floor( screen.x ) % 10 == 0 )
					OutColor = _DarkLineColor;
				else
					OutColor = _BGColor;

				// spotlight on player and ball position
				OutColor = spotlight( OutColor, screen, _PlayerPosition );
				OutColor = spotlight( OutColor, screen, _BallPosition );

				return OutColor;
			}
			ENDCG
		}
	}
}
