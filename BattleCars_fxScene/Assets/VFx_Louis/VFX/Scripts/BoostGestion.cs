using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BoostGestion : MonoBehaviour
{
    [Header("REFS")]
    public ParticleSystem[] MainFlame;
    //[Space]
    public ParticleSystem[] NitroTrail;


    //public float speedRatio { get; private set; }
    [Header("TWEAKING")]
    [Range(-1, 1)]
    public float speedRatio;
    [Range(0.1f, 40f)]
    public float maxOffsetX = 1;


    /// <summary>
    /// Input une valeur entre -1 et 1 (Axis value Input), permet d'update les différents VFX du drifts.
    /// </summary>
    public void SetSpeedRatio(float value)
    {
        speedRatio = value;
        ChangeDirection(MainFlame);
        ChangeDirection(NitroTrail);
    }

    private void ChangeDirection(ParticleSystem[] ps)
    {
        for (int i = 0; i < ps.Length; i++)
        {
            var vel = ps[i].velocityOverLifetime;
            vel.xMultiplier = maxOffsetX * -speedRatio;
            Debug.Log(ps[i].velocityOverLifetime.xMultiplier);
        }


    }

    private void Update()
    {
        ChangeDirection(MainFlame);
        ChangeDirection(NitroTrail);
    }
}