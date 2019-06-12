/*
 * Copyright (c) 2006, 2009 The Australian National University.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Apache License v2.0.
 * You may obtain the license at
 * 
 *    http://www.opensource.org/licenses/apache2.0.php
 */
package org.dacapo.harness;

/**
 * @date $Date: 2009-12-24 11:19:36 +1100 (Thu, 24 Dec 2009) $
 * @id $Id: EuroPAR19.java 738 2009-12-24 00:19:36Z steveb-oss $
 */
public class EuroPAR19 extends Callback {

  private boolean harness_start = false;

  public EuroPAR19(CommandLineArgs args) {
    super(args);
  }

  /* Immediately prior to start of the benchmark */
  @Override
  public void start(String benchmark) {
    if(iterations+1 == args.getIterations()) {
      harness_start = true;
      System.err.println("MMTk Harness Started");
      org.mmtk.plan.Plan.harnessBegin();
    }
    super.start(benchmark);
  };

  /* Immediately after the end of the benchmark */
  @Override
  public void stop(long duration) {
    super.stop(duration);
    System.err.flush();
  };

  @Override
  public void complete(String benchmark, boolean valid) {
    super.complete(benchmark, valid);
    System.err.println("my hook " + (valid ? "PASSED " : "FAILED ") + (isWarmup() ? "warmup " : "") + benchmark);
    if(harness_start) {
      org.mmtk.plan.Plan.harnessEnd();
    }
    System.err.flush();
  };
}
