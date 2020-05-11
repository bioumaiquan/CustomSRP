using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using BioumRP;

[CustomEditor(typeof(FogExtension))]
public class BiouFogExtensionEditor : Editor
{
    static class Styles
    {
        public static GUIContent fogColor = new GUIContent("雾颜色");
        public static GUIContent enableDistanceFog = new GUIContent("距离雾");
        public static GUIContent distanceStart = new GUIContent("起始距离");
        public static GUIContent distanceFalloff = new GUIContent("过度衰减");
        public static GUIContent enableHeightFog = new GUIContent("高度雾");
        public static GUIContent heightStart = new GUIContent("起始高度");
        public static GUIContent heightFalloff = new GUIContent("过度衰减");
        public static GUIContent enableSunScattering = new GUIContent("散射");
        public static GUIContent SunScatteringColor = new GUIContent("颜色");
        public static GUIContent SunScatteringStrength = new GUIContent("散射强度");
        public static GUIContent SunScatteringRange = new GUIContent("散射范围");
    }

    public override void OnInspectorGUI()
    {
        serializedObject.Update();

        EditorGUILayout.Space();
        EditorGUILayout.PropertyField(serializedObject.FindProperty("fogColor"), Styles.fogColor);
        EditorGUILayout.Space();
        DistanceFogGUI();
        EditorGUILayout.Space();
        HeightFogGUI();
        EditorGUILayout.Space();
        SunScatteringGUI();

        serializedObject.ApplyModifiedProperties();
    }

    void DistanceFogGUI()
    {
        SerializedProperty distanceFogToggle = serializedObject.FindProperty("distanceFog");
        EditorGUILayout.PropertyField(distanceFogToggle, Styles.enableDistanceFog);

        EditorGUI.indentLevel++;
        if (distanceFogToggle.boolValue)
        {
            EditorGUILayout.PropertyField(serializedObject.FindProperty("distanceStart"), Styles.distanceStart);
            EditorGUILayout.PropertyField(serializedObject.FindProperty("distanceFalloff"), Styles.distanceFalloff);
        }
        EditorGUI.indentLevel--;
    }

    void HeightFogGUI()
    {
        SerializedProperty heightFogToggle = serializedObject.FindProperty("heightFog");
        EditorGUILayout.PropertyField(heightFogToggle, Styles.enableHeightFog);

        EditorGUI.indentLevel++;
        if (heightFogToggle.boolValue)
        {
            EditorGUILayout.PropertyField(serializedObject.FindProperty("heightStart"), Styles.heightStart);
            EditorGUILayout.PropertyField(serializedObject.FindProperty("heightFalloff"), Styles.heightFalloff);
        }
        EditorGUI.indentLevel--;
    }

    void SunScatteringGUI()
    {
        SerializedProperty sunScatteringToggle = serializedObject.FindProperty("sunScattering");
        EditorGUILayout.PropertyField(sunScatteringToggle, Styles.enableSunScattering);

        EditorGUI.indentLevel++;
        if (sunScatteringToggle.boolValue)
        {
            //EditorGUILayout.PropertyField(serializedObject.FindProperty("SunScatteringColor"), Styles.SunScatteringColor);
            EditorGUILayout.PropertyField(serializedObject.FindProperty("sunScatteringStrength"), Styles.SunScatteringStrength);
            EditorGUILayout.PropertyField(serializedObject.FindProperty("sunScatteringRange"), Styles.SunScatteringRange);
        }
        EditorGUI.indentLevel--;
    }
}
