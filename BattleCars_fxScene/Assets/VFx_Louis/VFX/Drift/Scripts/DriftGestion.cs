using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DriftGestion : MonoBehaviour
{

    [Header("REFS")]
    public ParticleSystem[] SmokeVFX;
    [Space]
    public ParticleSystem[] SparkeVFX;
    [Space]
    public TrailRenderer[] tireTrailVFX;

    public float speedRatio { get; private set; }
    [Header("TWEAKING")]
    //[Range(-1, 1)]
    //public float speedRatio;
    [Range(0.1f, 20f)]
    [Tooltip("La valeur d'offset des particles sur le côté si le drift est à vitesse maximal")]
    public float maxOffsetX = 1;


    /// <summary>
    /// Input une valeur entre -1 et 1 (Axis value Input), permet d'update les différents VFX du drifts.
    /// </summary>
    public void SetSpeedRatio(float value)
    {
        speedRatio = value;
        if (speedRatio == 0)
        {
            DisableSparke(false);
        }
        else
        {
            DisableSparke(true);
        }
        ChangeSparkeDirection(speedRatio > 0 ? true : false);
        SmokeOffset();
    }

    /// <summary>
    /// Permet de désactiver/activer les VFx de drift
    /// </summary>
    /// <param name="toggle">active/désactive</param>
    public void ToggleDrift(bool toggle)
    {
        if (toggle)
        {
            gameObject.SetActive(true);
        }
        else
        {
            gameObject.SetActive(true);
        }
    }

    private void ChangeSparkeDirection(bool rigthDrift)
    {
        for (int i = 0; i < SparkeVFX.Length; i++)
        {
            var fxShape = SparkeVFX[i].shape;
            float arcDifference = (180 - fxShape.arc) / 2;

            fxShape.rotation = rigthDrift ? new Vector3(90, 90 - arcDifference, 0) : new Vector3(90, 270 - arcDifference, 0);
        }
    }

    private void SmokeOffset()
    {
        for (int i = 0; i < SmokeVFX.Length; i++)
        {
            var vel = SmokeVFX[i].velocityOverLifetime;
            vel.xMultiplier = maxOffsetX * -speedRatio;
            Debug.Log(SmokeVFX[i].velocityOverLifetime.xMultiplier);
        }

    }

    private void DisableSparke(bool toggle)
    {
        for (int i = 0; i < SparkeVFX.Length; i++)
        {
            SparkeVFX[i].gameObject.SetActive(toggle);
        }
    }

    #region Test
    //private void Update()
    //{
    //    #region Sparke Gestion
    //    if (speedRatio == 0)
    //    {
    //        DisableSparke(false);
    //    }
    //    else
    //    {
    //        DisableSparke(true);
    //    }
    //    ChangeSparkeDirection(speedRatio > 0 ? true : false);
    //    #endregion
    //    SmokeOffset();
    //}
    #endregion
}
