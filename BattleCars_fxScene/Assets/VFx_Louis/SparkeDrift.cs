using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SparkeDrift : MonoBehaviour
{
    public bool rightDrift;
    public ParticleSystem sparkMain;


    private void Awake()
    {
        ChangeDriftDirection(rightDrift);
    }

    private void Update()
    {
        ChangeDriftDirection(rightDrift);
    }

    public void ChangeDriftDirection(bool rigthDrift)
    {
        var fxShape = sparkMain.shape;
        float arcDifference = (180 - fxShape.arc) / 2;

        fxShape.rotation = rigthDrift ? new Vector3(90, 90 - arcDifference, 0) : new Vector3(90, 270 - arcDifference, 0);
    }
}
